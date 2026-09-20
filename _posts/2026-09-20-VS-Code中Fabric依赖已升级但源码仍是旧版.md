---
layout: single
title: "VS Code 中 Fabric 依赖已升级但源码仍是旧版：一次 Java 项目模型未刷新的排查记录"
slug: "vscode-fabric-old-source-after-gradle-upgrade"
excerpt: "记录一次 Minecraft Fabric 26.3 升级后的排查：Gradle 已解析到新版 Fabric API，但 VS Code 跳转到的 FabricRecipeProvider 仍来自旧版 JAR。最终通过 Java: Import Java Projects into Workspace 重新导入 Java/Gradle 项目后解决。"
categories: 技术 Java Gradle
tags: [Minecraft, Fabric, Fabric API, Gradle, VS Code, Java, Datagen, 故障排查]
hidden: false
---

## 前言

在升级 Minecraft Fabric Mod 项目时，我遇到了一个很容易误判的问题：

**Gradle 的依赖已经更新到了新版本，但 VS Code 中跳转到的依赖源码却仍然是旧版本。**

这会造成一种非常迷惑的现象：

- Gradle / `javac` 按照新版 API 编译；
- VS Code 的“转到定义”却显示旧版 API；
- 编译器要求实现的方法签名，与编辑器里看到的父类源码对不上。

这次问题最终并不在 Fabric API，也不在 Gradle 依赖解析，而是 **VS Code 的 Java 项目模型没有及时重新导入**。

解决方法非常简单：

```text
Ctrl + Shift + P
→ Java: Import Java Projects into Workspace
```

执行后，VS Code 重新导入 Gradle Java 项目，新版依赖源码随之正确加载。

这篇文章记录完整现象、判断过程和以后遇到类似问题时的最短排查方法。

---

## 1. 问题背景

项目升级到了 Minecraft 26.3，并使用：

```text
fabric-api:0.161.0+26.3
```

在构建项目时，`compileClientJava` 报错：

```text
FireArrowRecipeProvider不是抽象的,
并且未覆盖FabricRecipeProvider中的抽象方法
createRecipeProvider(
    Provider,
    BootstrapContext<Recipe<?>>,
    BootstrapContext<Advancement>
)
```

同时还有：

```text
方法不会覆盖或实现超类型的方法
```

以及：

```text
Provider无法转换为BootstrapContext<Recipe<?>>
```

这说明当前实际参与编译的 `FabricRecipeProvider` 已经采用了新的 API。

然而，在 VS Code 中打开：

```java
FabricRecipeProvider
```

看到的源码却仍然调用：

```java
createRecipeProvider(registries, recipeOutput)
```

也就是旧版的双参数形式。

更明显的是，VS Code 显示这个源码来自：

```text
fabric-data-generation-api-v1-24.0.17+35c80edcb3.jar
```

于是出现了一个看起来矛盾的情况：

```text
编译器：
要求新版三参数 API

VS Code：
显示旧版双参数 API
```

---

## 2. 不要先猜，先确认 Gradle 实际用了哪个版本

遇到这种“编辑器源码和编译器报错不一致”的情况，首先应该确认：

> **Gradle 真正用于编译的依赖到底是什么版本？**

执行：

```powershell
.\gradlew dependencyInsight --dependency fabric-data-generation-api-v1 --configuration clientCompileClasspath
```

实际得到：

```text
> Task :dependencyInsight

net.fabricmc.fabric-api:fabric-data-generation-api-v1:27.2.4+427eab975d
  Variant compile:
    | Attribute Name                 | Provided | Requested    |
    |--------------------------------|----------|--------------|
    | org.gradle.status              | release  |              |
    | org.gradle.category            | library  | library      |
    | org.gradle.libraryelements     | jar      | classes      |
    | org.gradle.usage               | java-api | java-api     |
    | org.gradle.dependency.bundling |          | external     |
    | org.gradle.jvm.environment     |          | standard-jvm |
    | org.gradle.jvm.version         |          | 25           |

net.fabricmc.fabric-api:fabric-data-generation-api-v1:27.2.4+427eab975d
\--- net.fabricmc.fabric-api:fabric-api:0.161.0+26.3
     \--- clientCompileClasspath
```

这里最重要的是：

```text
fabric-data-generation-api-v1:27.2.4+427eab975d
```

这证明 **Gradle 实际参与编译的已经是新版依赖**。

所以问题不是：

```text
Gradle 仍然用了旧版 Fabric API
```

而是：

```text
Gradle：
27.2.4 ✅

VS Code 中看到的源码：
24.0.17 ❌
```

到这里，问题范围就已经非常明确了。

---

## 3. 为什么会出现这种现象？

Gradle 与 VS Code 的 Java 代码分析并不是完全同一个系统。

可以简单理解为：

```text
build.gradle / gradle.properties
        │
        ▼
      Gradle
        │
        ├── 真正解析依赖
        ├── 生成 compileClasspath
        └── 调用 javac 编译
```

而 VS Code 的代码补全、跳转定义、类型分析，则主要依赖 Java 扩展维护的项目模型：

```text
VS Code
   │
   ▼
Java Language Server
   │
   ├── 导入 Gradle 项目
   ├── 建立 classpath
   ├── 建立符号索引
   └── 关联依赖源码
```

因此，在升级依赖以后可能出现：

```text
Gradle 项目模型
已经更新

        但是

VS Code Java 项目模型
仍然保留旧状态
```

结果就是：

> 命令行构建看到的是新版类，编辑器跳转看到的却还是旧版源码。

这类问题尤其容易出现在以下场景：

- 修改了 `gradle.properties` 中的 Minecraft / Fabric 版本；
- 升级了 Fabric API；
- 升级 Fabric Loom；
- 切换 Git 分支后依赖版本变化；
- 打开过同一个项目的旧版本；
- VS Code 长时间没有重新导入 Gradle Java 项目。

---

## 4. 最终解决方法

我这次最终使用的解决方法不是删除 Gradle 缓存，也不是重新安装 Fabric，而是在 VS Code 中执行：

```text
Ctrl + Shift + P
```

搜索并运行：

```text
Java: Import Java Projects into Workspace
```

执行后，让 VS Code 重新完成 Java / Gradle 项目导入。

重新打开：

```java
FabricRecipeProvider
```

此时源码已经更新为与当前 Gradle 依赖一致的版本。

也就是说，这次真正有效的操作就是：

```text
Java: Import Java Projects into Workspace
```

---

## 5. 为什么这个命令能解决问题？

这个命令会让 Java 扩展重新识别工作区中的 Java 项目，并重新建立项目模型。

对于 Gradle 项目，它最重要的作用是重新同步：

```text
Gradle 配置
    ↓
依赖关系
    ↓
Java classpath
    ↓
依赖 JAR
    ↓
源码关联
    ↓
VS Code 符号索引
```

因此，当 Gradle 已经解析到新版依赖，但 VS Code 仍然显示旧源码时，它可以把两边重新同步起来。

这也是为什么仅仅执行：

```powershell
.\gradlew clean
```

通常解决不了这个问题。

`clean` 主要删除的是：

```text
build/
```

它并不会直接要求 VS Code 的 Java Language Server 重新导入整个项目模型。

---

## 6. `clean`、`--refresh-dependencies` 和重新导入 Java 项目的区别

这三个操作解决的问题不同。

### `gradlew clean`

```powershell
.\gradlew clean
```

主要清理项目构建输出：

```text
build/
```

适合处理：

- 旧 class 文件；
- 旧构建产物；
- 部分增量构建问题。

但它不是针对 VS Code Java 索引的。

---

### `--refresh-dependencies`

```powershell
.\gradlew --refresh-dependencies
```

主要作用是让 Gradle 重新检查、解析依赖。

适合：

- Gradle 本身仍解析到错误版本；
- SNAPSHOT / changing dependency 没有更新；
- 缓存中的依赖元数据需要重新验证。

如果：

```powershell
.\gradlew dependencyInsight ...
```

已经明确显示正确的新版本，那么通常没有必要先大规模清 Gradle 缓存。

---

### `Java: Import Java Projects into Workspace`

这是这次真正需要的操作。

它解决的是：

```text
Gradle 是新的
+
VS Code 还是旧的
```

也就是编辑器的 Java 项目模型、classpath 和源码索引没有跟上 Gradle。

---

## 7. 推荐的最短排查流程

以后再遇到类似问题，我会按照下面的顺序排查。

首先看 Gradle 真正使用的版本：

```powershell
.\gradlew dependencyInsight --dependency <依赖名> --configuration clientCompileClasspath
```

例如：

```powershell
.\gradlew dependencyInsight --dependency fabric-data-generation-api-v1 --configuration clientCompileClasspath
```

然后分两种情况。

### 情况 A：Gradle 本身还是旧版本

例如：

```text
dependencyInsight
→ 仍然显示旧依赖
```

这时才应该检查：

```text
build.gradle
gradle.properties
settings.gradle
libs.versions.toml
```

并视情况执行：

```powershell
.\gradlew --refresh-dependencies
```

---

### 情况 B：Gradle 是新版，但 VS Code 显示旧源码

例如这次：

```text
Gradle：
fabric-data-generation-api-v1 27.2.4

VS Code：
fabric-data-generation-api-v1 24.0.17
```

直接优先执行：

```text
Ctrl + Shift + P
→ Java: Import Java Projects into Workspace
```

这是这次最有效、成本最低的解决方法。

---

## 8. 如果重新导入后仍然异常

如果 `Java: Import Java Projects into Workspace` 还不能解决，可以再逐级尝试。

首先：

```text
Ctrl + Shift + P
→ Java: Clean Java Language Server Workspace
```

然后让 VS Code 重启 Java Language Server。

必要时再执行：

```powershell
.\gradlew --refresh-dependencies
```

并重新导入项目。

不建议一开始就删除整个：

```text
%USERPROFILE%\.gradle\caches
```

因为 Minecraft + Fabric + Loom 项目的 Gradle 缓存通常较大，全部删除会导致大量依赖重新下载。

正确思路应该是：

```text
先确认到底是谁旧了
        ↓
Gradle 旧？
还是 VS Code 旧？
        ↓
针对对应层处理
```

---

## 9. 这次问题最容易产生的误判

### 误判一：VS Code 打开的源码一定就是编译时使用的源码

不一定。

如果 Java 项目模型没有及时刷新，编辑器完全可能继续关联旧 JAR 的源码。

因此遇到：

```text
IDE 显示的方法签名
≠
javac 报错中要求的方法签名
```

不要立即认为编译器有问题。

优先检查真实依赖树。

---

### 误判二：Fabric API 总版本和内部模块版本应该一致

项目中使用的是：

```text
fabric-api:0.161.0+26.3
```

但其中的 Data Generation 模块实际是：

```text
fabric-data-generation-api-v1:27.2.4+427eab975d
```

这是正常现象。

Fabric API 是多个模块的聚合依赖，各模块拥有自己的版本号。

因此不能因为：

```text
0.161.0
```

和：

```text
27.2.4
```

不同，就认为发生了依赖冲突。

---

### 误判三：出现依赖问题就应该删除 Gradle 缓存

也不一定。

这次 `dependencyInsight` 已经清楚证明：

```text
Gradle = 正确版本
```

这意味着继续删除 Gradle 缓存并不能直接解决 VS Code Java Language Server 的旧索引问题。

先定位问题属于哪一层，比“全部清缓存”更有效。

---

## 10. 最终经验总结

这次排查可以浓缩成一句话：

> **当 Gradle 编译器使用的 API 与 VS Code 跳转看到的依赖源码不一致时，先用 `dependencyInsight` 判断 Gradle 的真实依赖版本；如果 Gradle 已经正确，而 VS Code 仍显示旧 JAR，则优先执行 `Java: Import Java Projects into Workspace` 重新导入 Java 项目。**

我的实际情况是：

```text
Minecraft / Fabric 项目升级
        ↓
Gradle 已解析新版 Fabric API
        ↓
dependencyInsight 显示：
fabric-data-generation-api-v1:27.2.4
        ↓
VS Code 仍显示：
fabric-data-generation-api-v1:24.0.17
        ↓
执行：
Java: Import Java Projects into Workspace
        ↓
Java / Gradle 项目重新导入
        ↓
依赖源码恢复为新版
        ↓
问题解决
```

以后遇到 Fabric、Forge、NeoForge 或普通 Java Gradle 项目中类似的“**构建依赖已更新，但 VS Code 代码提示和依赖源码仍然是旧版**”问题，这套判断方法同样适用。

---

## 速查

最重要的两个操作：

```powershell
# 查看 Gradle 真正解析到的依赖版本
.\gradlew dependencyInsight --dependency fabric-data-generation-api-v1 --configuration clientCompileClasspath
```

以及 VS Code：

```text
Ctrl + Shift + P
→ Java: Import Java Projects into Workspace
```

如果第一条已经显示新版，而 VS Code 仍显示旧版，优先使用第二条。
