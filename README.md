# 五子棋大师

## 一、游戏截图

## 二、功能介绍

### 1. 人机对战

在人机模式下，AI 共有三种难度可供选择。简单难度的 AI 由贪心算法实现，中等和困难难度的 AI 基于极小化极大算法实现。算法通过多种方式优化，在困难难度下，博弈树深度可达8层。

#### 1.1 贪心算法

贪心算法的主要思路是，评价当前棋局中所有可以下的位置，依据一个评分表对该位置进行打分，然后随机选取一个分数最高的位置落子。对于五子棋来说，我们把五个连续的位置称为五元组，对于一个可以下的位置来说，我们对于所有包含它的五元组，根据五元组中黑棋和白棋的数量进行评分，这个位置的最终得分就是所有这些五元组的评分的和。下面是游戏中所用的针对黑棋的评分表：

```c
// tuple is empty  
GGTupleTypeBlank = 7,  
// tuple contains a black chess  
GGTupleTypeB = 35,  
// tuple contains two black chesses  
GGTupleTypeBB = 800,  
// tuple contains three black chesses  
GGTupleTypeBBB = 15000,  
// tuple contains four black chesses  
GGTupleTypeBBBB = 800000,  
// tuple contains a white chess  
GGTupleTypeW = 15,  
// tuple contains two white chesses  
GGTupleTypeWW = 400,  
// tuple contains three white chesses  
GGTupleTypeWWW = 1800,  
// tuple contains four white chesses  
GGTupleTypeWWWW = 100000,  
// tuple contains at least one black and at least one white  
GGTupleTypePolluted = 0
```

#### 1.2 极小化极大算法

对于五子棋这种零和游戏，极小化极大算法是最常用的算法，维基百科上已有详细介绍：[极小化几大算法](https://en.wikipedia.org/wiki/Minimax)，在此不再详细解释。

游戏在博弈树搜索的基础之上，进行了许多优化，用于提升搜索树的深度：

**Alpha-Beta 剪枝**，维基百科上的详细介绍：[Alpha-Beta 剪枝](https://en.wikipedia.org/wiki/Alpha%E2%80%93beta_pruning)。

**启发式搜索函数**：在博弈树中，对于每一层的节点来说，如果粗略的按照好坏对其进行一个排序，Alpha-Beta 算法就可以减去更多的节点，游戏中，我们用贪心算法对于每一个节点上一步所下的位置进行评分，根据这个评分对节点进行排序，从而进一步提升博弈树搜索的效率。

**缩减子节点**：游戏中所使用的贪心算法效果很好，基本可以保证最优解在评分前十的点中，所以我们可以缩减博弈树中的每个节点的子节点数量，只取评分前十的点，这大大的减少了节点的数量，并且将博弈树的搜索深度提升到了8层。

**迭代加深**：在游戏中有时候会发生如下情况：明明 AI 已经快要胜利，但是会选择一些其他的点并且多下几部才取胜，看起来像是在调戏玩家，实际上这是由于在博弈树中已经找到一个解之后便没有考虑其他层数较小的解。归根结底是因为极小化极大算法是深度优先搜索，不保证可以找到最优解。对此我们使用迭代加深博弈树搜索深度的方法，确保 AI 可以返回最优解。

### 2. 双人同屏

### 3. 联机游戏

### 4. 其他功能

#### 4.1 界面设计

由于没有美工，游戏没有华丽的特效，但整体界面依然不失简洁优雅大方，五子棋的棋盘使用 Core Graphics 画出，并使用 NSTimer 对游戏双方进行计时，落子指示图标也可以方便的提醒玩家最新落子。

#### 4.2 游戏设置
在设置界面可以设置游戏的难度，游戏的音乐以及音效，玩家的偏好设置通过 NSUsersDefaults 进行存储。游戏的音乐使用 AVAudioPlayer 进行播放与控制。

## 三、总结

该五子棋游戏具有人机、人人、联机等多种功能，并且棋力不俗，在实际测试中可以轻松战胜大多数网络上的五子棋程序。

下面是我们的五子棋与 Google 搜索 Gomoku 排名第一的[五子棋游戏](http://gomoku.yjyao.com/)进行对战的截图：

![]()

先手情况下，轻松取胜。

![]()

后手情况下，经过一番鏖战，取得胜利。

下面是与 Github 上面有名的五子棋程序 [Gobang](https://github.com/lihongxun945/gobang) 进行对战的截图：

![]()

由于 GoBang 不能设置先后手，这是在我方后手的情况下，最终取得了胜利。

## 四、参考资料

[Core Graphics](https://www.raywenderlich.com/90690/modern-core-graphics-with-swift-part-1)

[五子棋项目参考1](https://github.com/dadahua/GoBangProject)

[五子棋项目参考2](http://www.jianshu.com/p/a2f98c138648)

[五子棋AI设计](http://blog.csdn.net/pi9nc/article/details/10858411)

[如何设计一个还可以的五子棋AI](https://kimlongli.github.io/2016/12/14/%E5%A6%82%E4%BD%95%E8%AE%BE%E8%AE%A1%E4%B8%80%E4%B8%AA%E8%BF%98%E5%8F%AF%E4%BB%A5%E7%9A%84%E4%BA%94%E5%AD%90%E6%A3%8BAI/)

**[五子棋AI算法系列](http://blog.csdn.net/lihongxun945/article/details/50622880)**

**[人机版五子棋两种算法概述](http://blog.csdn.net/onezeros/article/details/5542379)**

**[计算机五子棋博奕系统的研究与实现](http://www.taodocs.com/p-20517708.html)**

**[Gomoku AI Player](https://www.cs.cf.ac.uk/PATS2/@archive_file?c=&p=file&p=526&n=final&f=1-1224795-final-report.pdf)**

**[十四步实现拥有强大AI的五子棋游戏](http://www.cnblogs.com/goodness/archive/2010/05/27/1745756.html)**

**[Creating a Game with Bonjour and GCDAsyncUdpSocket - Server and Client Setup](https://code.tutsplus.com/tutorials/creating-a-game-with-bonjour-client-and-server-setup--mobile-16233)**

**[Creating a Game with Bonjour and GCDAsyncUdpSocket - Sending Data](https://code.tutsplus.com/tutorials/creating-a-game-with-bonjour-sending-data--mobile-16437)**