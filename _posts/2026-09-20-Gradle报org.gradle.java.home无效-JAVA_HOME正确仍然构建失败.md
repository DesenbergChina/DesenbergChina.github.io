---
layout: single
title: "Gradle 报 org.gradle.java.home 无效：为什么 JAVA_HOME 正确仍然构建失败"
slug: "gradle-invalid-java-home"
excerpt: "记录一次 Gradle 构建失败排查：项目级 gradle.properties 已注释 org.gradle.java.home，JAVA_HOME 也正确，但 Gradle 仍然读取旧 JDK 路径。最终定位到用户级 ~/.gradle/gradle.properties 中残留的配置。"
categories: 技术 Java Gradle
tags: [Gradle, Java, JDK, JAVA_HOME, Windows, PowerShell, 故障排查]
hidden: false
---

## 前言

在构建一个 Gradle 项目时，我遇到了下面这个错误：

```text
FAILURE: Build failed with an exception.

* What went wrong:
Value 'D:/Program Files/java/jdk-25' given for org.gradle.java.home Gradle property is invalid (Java home supplied is invalid)
```

第一反应是项目中的 `gradle.properties` 配置错了，于是我把：

```properties
org.gradle.java.home=D:/Program Files/java/jdk-25
```

注释掉：

```properties
# org.gradle.java.home=D:/Program Files/java/jdk-25
```

同时检查环境变量：

```powershell
$env:JAVA_HOME
```

输出也是正确的：

```text
C:\Program Files\Microsoft\jdk-25.0.4.101-hotspot\
```

但 Gradle 仍然继续报完全相同的错误。

最终发现，问题并不在当前项目的 `gradle.properties`，而是：

```text
C:\Users\<用户名>\.gradle\gradle.properties
```

里面仍然存在旧的：

```properties
org.gradle.java.home=D:/Program Files/java/jdk-25
```

这篇文章记录完整排查过程，以及以后遇到类似问题时最短的处理方法。

---

## 1. 典型现象

错误信息：

```text
Value 'D:/Program Files/java/jdk-25' given for org.gradle.java.home Gradle property is invalid
```

但系统中的 JDK 实际安装位置可能是：

```text
C:\Program Files\Microsoft\jdk-25.0.4.101-hotspot\
```

检查：

```powershell
$env:JAVA_HOME
```

返回：

```text
C:\Program Files\Microsoft\jdk-25.0.4.101-hotspot\
```

甚至下面这个文件也真实存在：

```powershell
Test-Path "$env:JAVA_HOME\bin\java.exe"
```

返回：

```text
True
```

这时很容易产生疑问：

> JAVA_HOME 明明是正确的，为什么 Gradle 还在读取另一个完全不同的 JDK 路径？

原因是：**Gradle 并不只从 JAVA_HOME 决定自己使用哪个 JDK。**

---

## 2. 关键原因：org.gradle.java.home 会覆盖 JAVA_HOME

Gradle 可以通过：

```properties
org.gradle.java.home=...
```

显式指定 Gradle 使用的 Java Home。

只要这个属性仍然存在，Gradle 就可能优先使用它，而不是你当前 PowerShell 中的：

```text
JAVA_HOME
```

因此下面两个配置可以同时存在：

```text
JAVA_HOME
    ↓
C:\Program Files\Microsoft\jdk-25.0.4.101-hotspot

org.gradle.java.home
    ↓
D:/Program Files/java/jdk-25
```

此时真正导致失败的是第二个路径。

所以：

> **JAVA_HOME 正确，不等于 Gradle 实际使用的 Java Home 正确。**

---

## 3. 最容易漏掉的位置：用户级 gradle.properties

我最开始只修改了项目目录中的：

```text
<project>\gradle.properties
```

把：

```properties
org.gradle.java.home=D:/Program Files/java/jdk-25
```

注释掉。

但 Gradle 还有用户级配置文件：

```text
%USERPROFILE%\.gradle\gradle.properties
```

在 Windows 上一般对应：

```text
C:\Users\<用户名>\.gradle\gradle.properties
```

打开它：

```powershell
notepad "$env:USERPROFILE\.gradle\gradle.properties"
```

结果发现里面仍然有：

```properties
org.gradle.java.home=D:/Program Files/java/jdk-25
```

也就是说：

```text
项目 gradle.properties
    ↓
已经注释

用户级 ~/.gradle/gradle.properties
    ↓
仍然保留旧配置

Gradle
    ↓
继续读取旧 JDK 路径
    ↓
构建失败
```

这就是这次问题真正的原因。

---

## 4. 最短修复方法

如果遇到同样的问题，先检查：

```powershell
Get-Content "$env:USERPROFILE\.gradle\gradle.properties" -ErrorAction SilentlyContinue
```

如果看到：

```properties
org.gradle.java.home=D:/Program Files/java/jdk-25
```

直接删除，或者注释：

```properties
# org.gradle.java.home=D:/Program Files/java/jdk-25
```

然后确认当前 `JAVA_HOME`：

```powershell
$env:JAVA_HOME
```

再确认 Java 可执行文件真实存在：

```powershell
Test-Path "$env:JAVA_HOME\bin\java.exe"
```

如果返回：

```text
True
```

再运行：

```powershell
& "$env:JAVA_HOME\bin\java.exe" -version
```

最后重新检查 Gradle：

```powershell
.\gradlew --version
```

---

## 5. 一条命令查出所有残留配置

如果不知道旧配置到底藏在哪里，可以直接搜索用户目录中的所有 `gradle.properties`：

```powershell
Get-ChildItem -Path "$env:USERPROFILE" -Filter "gradle.properties" -Recurse -ErrorAction SilentlyContinue |
    Select-String "org.gradle.java.home"
```

它会直接显示：

```text
文件路径
行号
匹配内容
```

例如：

```text
C:\Users\xxx\.gradle\gradle.properties:3:
org.gradle.java.home=D:/Program Files/java/jdk-25
```

这比一个目录一个目录手工寻找快很多。

如果只想检查当前项目和 Gradle 用户目录，也可以缩小范围：

```powershell
Get-ChildItem -Path "$env:USERPROFILE\.gradle", "." -Filter "gradle.properties" -Recurse -ErrorAction SilentlyContinue |
    Select-String "org.gradle.java.home"
```

---

## 6. 还要检查哪些地方

如果删除用户级配置后仍然有问题，还可以检查环境变量。

### 检查 JAVA_HOME

```powershell
$env:JAVA_HOME
```

### 检查 GRADLE_OPTS

```powershell
$env:GRADLE_OPTS
```

某些环境中可能存在：

```text
-Dorg.gradle.java.home=D:/Program Files/java/jdk-25
```

### 检查 JAVA_OPTS

```powershell
$env:JAVA_OPTS
```

### 检查 Gradle 项目属性环境变量

```powershell
$env:ORG_GRADLE_PROJECT_org_gradle_java_home
```

因此，完整排查时可以直接执行：

```powershell
"JAVA_HOME=$env:JAVA_HOME"
"GRADLE_OPTS=$env:GRADLE_OPTS"
"JAVA_OPTS=$env:JAVA_OPTS"
"ORG_GRADLE_PROJECT_org_gradle_java_home=$env:ORG_GRADLE_PROJECT_org_gradle_java_home"
```

---

## 7. 别忘了 Gradle Daemon

Gradle 会使用 Daemon 长时间驻留。

修改 Java 配置后，可以先停止已有 Daemon：

```powershell
.\gradlew --stop
```

然后重新运行：

```powershell
.\gradlew --version
```

如果配置正常，可以进一步重新构建：

```powershell
.\gradlew build
```

不过需要注意：

> 如果 `.\gradlew --stop` 本身都因为非法的 `org.gradle.java.home` 无法启动，那么应先删除或修正导致错误的配置，再执行停止 Daemon 的操作。

---

## 8. org.gradle.java.home 应该指向哪里

如果确实需要显式配置：

```properties
org.gradle.java.home=...
```

它应该指向 **JDK 根目录**。

例如：

```text
C:\Program Files\Microsoft\jdk-25.0.4.101-hotspot
```

这个目录下面应该直接存在：

```text
bin\java.exe
```

也就是：

```text
C:\Program Files\Microsoft\jdk-25.0.4.101-hotspot
├── bin
│   ├── java.exe
│   ├── javac.exe
│   └── ...
├── conf
├── include
├── jmods
└── lib
```

不要写成：

```properties
org.gradle.java.home=C:/Program Files/Microsoft/jdk-25.0.4.101-hotspot/bin
```

而应该写：

```properties
org.gradle.java.home=C:/Program Files/Microsoft/jdk-25.0.4.101-hotspot
```

---

## 9. 是否一定要配置 org.gradle.java.home

不一定。

如果系统已经正确配置：

```text
JAVA_HOME
```

而且：

```powershell
java -version
```

和：

```powershell
.\gradlew --version
```

都符合项目要求，那么通常可以不在 `gradle.properties` 中额外写：

```properties
org.gradle.java.home=...
```

这样做的好处是避免把某台电脑的绝对路径写进项目配置。

例如：

```properties
org.gradle.java.home=D:/Program Files/java/jdk-25
```

明显依赖某一台机器的目录结构。

项目换电脑、JDK 升级、JDK 安装目录变化后，都容易失效。

---

## 10. 我这次问题的完整因果链

这次故障可以概括成：

```text
以前配置过：
org.gradle.java.home=D:/Program Files/java/jdk-25
              ↓
JDK 实际位置后来变成：
C:\Program Files\Microsoft\jdk-25.0.4.101-hotspot
              ↓
项目 gradle.properties 中旧配置已经注释
              ↓
但用户级：
C:\Users\<用户名>\.gradle\gradle.properties
仍然保留旧配置
              ↓
Gradle 继续读取：
D:/Program Files/java/jdk-25
              ↓
路径不存在 / 不是有效 JDK Home
              ↓
Java home supplied is invalid
```

而：

```text
JAVA_HOME=C:\Program Files\Microsoft\jdk-25.0.4.101-hotspot
```

虽然正确，但并没有解决问题，因为真正生效的旧配置仍然存在。

---

## 11. 以后遇到这个错误，我会这样排查

首先确认错误里 Gradle **实际读取的路径**：

```text
Value 'XXX' given for org.gradle.java.home
```

然后检查：

```powershell
$env:JAVA_HOME
```

确认 JDK：

```powershell
Test-Path "$env:JAVA_HOME\bin\java.exe"
```

接着直接全局搜索：

```powershell
Get-ChildItem -Path "$env:USERPROFILE" -Filter "gradle.properties" -Recurse -ErrorAction SilentlyContinue |
    Select-String "org.gradle.java.home"
```

重点检查：

```text
项目目录\gradle.properties

以及

%USERPROFILE%\.gradle\gradle.properties
```

修正后：

```powershell
.\gradlew --stop
.\gradlew --version
.\gradlew build
```

这套顺序基本可以快速定位绝大多数类似问题。

---

## 总结

这次最重要的经验不是“重新设置 JAVA_HOME”，而是：

> **当 Gradle 错误明确提到 `org.gradle.java.home` 时，不要只盯着 `JAVA_HOME`。**

尤其是在 Windows 上，除了项目中的：

```text
gradle.properties
```

还应该立刻检查：

```text
%USERPROFILE%\.gradle\gradle.properties
```

如果 Gradle 报错中始终出现一个你明明已经从项目配置里删除的旧路径，那么几乎可以断定：

**还有另一个配置来源正在覆盖当前项目。**

以后遇到这种情况，直接搜索：

```powershell
Get-ChildItem -Path "$env:USERPROFILE" -Filter "gradle.properties" -Recurse -ErrorAction SilentlyContinue |
    Select-String "org.gradle.java.home"
```

往往比反复修改 `JAVA_HOME` 更快找到真正的问题。
