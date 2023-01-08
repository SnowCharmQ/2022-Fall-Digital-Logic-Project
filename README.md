# 2022-Fall-Digital-Logic-Project

### 1、约束文件输入输出端口解释

```
N5 rx 输入，提供给uart模块
T4 tx 输入，提供给uart模块
R11 rst 输入按钮，作为重置信号
P17 sys_clk 输入时钟信号
H4 front_detector 输出，uart模块检测障碍信号
J3 back_detector 输出，uart模块检测障碍信号
J2 left_detector 输出，uart模块检测障碍信号
K2 right_detector 输出，uart模块检测障碍信号
P4 move_backward_signal 输入开关，在手动模式作为倒车指令，在半自动模式作为调头信号指令
P5 move_forward_signal 输入开关，在半自动模式作为前进信号指令
P3 turn_left_signal 输入开关，作为左转信号指令
P2 turn_right_signal 输入开关，作为右转信号指令
G4 move_backward_light 输出灯光，未使用
F6 move_forward_light 输出灯光，未使用
G3 turn_left_light 输出灯光，在手动模式指示左转
J4 turn_right_light 输出灯光，在手动模式指示右转
T3 place_barrier_signal 输入开关，未使用
T5 destroy_barrier_signal 输入开关，未使用
R1 clutch 输入开关，在手动模式作为离合器
N4 throttle 输入开关，在手动模式作为油门
M4 brake 输入开关，在手动模式作为刹车
R15 power_on 输入按钮，作为全局电源开关，按下一秒后电源开启
R17 power_off 输出按钮，作为全局电源开关，按下后电源关闭
K1 power_light 输出灯光，指示电源开启状态
K3 state_light[0] 输出灯光，指示行驶状态
M1 state_light[1 输出灯光，指示行驶状态
L1 state_light[2] 输出灯光，指示行驶状态
K6 moving_light[0] 输出灯光，在手动模式指示移动状态
J5 moving_light[1] 输出灯光，在手动模式指示移动状态
H6 moving_light[2] 输出灯光，在手动模式指示移动状态
H5 moving_light[3] 输出灯光，在手动模式指示移动状态
U3 global_state[0] 输入按钮，更换全局手动、半自动和自动模式
U2 global_state[1] 输入按钮，更换全局手动、半自动和自动模式
B4 seg1[7] 输出信号，七段数码管显示
A4 seg1[6] 输出信号，七段数码管显示
A3 seg1[5] 输出信号，七段数码管显示
B1 seg1[4] 输出信号，七段数码管显示
A1 seg1[3] 输出信号，七段数码管显示
B3 seg1[2] 输出信号，七段数码管显示
B2 seg1[1] 输出信号，七段数码管显示
D5 seg1[0] 输出信号，七段数码管显示
D4 seg2[7] 输出信号，七段数码管显示
E3 seg2[6] 输出信号，七段数码管显示
D3 seg2[5] 输出信号，七段数码管显示
F4 seg2[4] 输出信号，七段数码管显示
F3 seg2[3] 输出信号，七段数码管显示
E2 seg2[2] 输出信号，七段数码管显示
D2 seg2[1] 输出信号，七段数码管显示
H2 seg2[0] 输出信号，七段数码管显示
G2 an[7] 输出信号，七段数码管显示
C2 an[6] 输出信号，七段数码管显示
C1 an[5] 输出信号，七段数码管显示
H1 an[4] 输出信号，七段数码管显示
G1 an[3] 输出信号，七段数码管显示
F1 an[2] 输出信号，七段数码管显示
E1 an[1] 输出信号，七段数码管显示
G6 an[0] 输出信号，七段数码管显示
```

### 2、不同模式端口指示

​		当前系统中，电源开启按钮长按一秒即可开启小车电源，电源关闭按钮按下就会关闭小车电源。电源指示灯指示了电源的状态，电源指示灯亮起代表小车电源开启，电源指示灯熄灭代表小车电源关闭。模式转换开关用于切换小车行驶模式，两个开关同时处于关闭状态小车处于手动行驶模式；左数第一个开关关闭第二个开关开启时小车处于半自动行驶模式；左数第一个开关开启第二个关闭状态时小车处于自动行驶模式。重置按钮用于重置小车当前状态。

#### 2.1、手动模式

![QQ图片20230107021616](https://s2.loli.net/2023/01/07/IkFDxdymBQeK7cN.jpg)

​		在手动模式中，离合器、油门、刹车、倒车、左转、右转开关均对应实际小车的离合器、油门、刹车、倒车、左转指示、右转指示，开关上拨代表激活状态。左转向灯和右转向灯同时亮起时代表小车处于未开始状态，在小车处于行驶状态时左右转向灯单独亮起用于指示左右转向。状态指示灯光和移动方向指示灯均用于指示当前小车的行驶状态。里程表于七段数码管处显示，随着小车前进或后退里程表上显示的数字匀速增大。

#### 2.2、半自动模式

![QQ图片20230107021610](https://s2.loli.net/2023/01/07/yFV9ZCSOKrftLgG.jpg)

​		在半自动模式中，前进、调头、左转、右转开关用于小车行驶到岔口处于等待状态时拨动，向小车发出对应的前进、调头、左转、右转指令，当小车处于行驶中拨动开关对小车不起影响。状态指示灯光和移动状态指示灯均用于指示当前小车的行驶状态。

#### 2.3、自动模式

![QQ图片20230108140051](https://s2.loli.net/2023/01/08/oDgNFSCsRWandG7.jpg)

​		在自动模式中，在开启电源进入自动行驶模式后不再需要开发板按钮和开关操作小车，所有灯光均用于指示小车行驶状态。

## 六、系统结构设计

### 1、状态流程图

#### 1.1、手动模式

 ![QQ图片20230107115658](https://s2.loli.net/2023/01/07/6VASx9gKFTnMoNf.jpg)

#### 1.2、半自动模式

![QQ图片20230107123806](https://s2.loli.net/2023/01/07/lsKnYzwWkfLrcPt.jpg)

#### 1.3、自动模式

![QQ图片20230108141512](https://s2.loli.net/2023/01/08/x6CJsbL8QWRKOPq.jpg)

### 2、电路结构框图

##### Schematic: 73 Cells, 57 IO/ports, 149 Nets

![image-20230108203352975](https://s2.loli.net/2023/01/08/RXJvUDg8WAkOPmt.png)

### 3、模块相互关系

![QQ图片20230107203315](https://s2.loli.net/2023/01/07/qoFOS9lwUCf1KWV.jpg)

​		在本系统中，顶层模块调用了引擎模块、手动行驶模块、半自动行驶模块、自动行驶模块和UART模块。引擎模块、半自动行驶模块、自动行驶模块调用了分频器模块用于使用不同频率的时钟信号；手动行驶模块调用了里程表模块，使得小车处于向前或向后行驶状态时开发板上的七段数码管作为里程表计数器匀速增加；UART模块仍为DEMO中所给文件未加以修改。

### 4、模块功能介绍

#### 4.1、顶层模块

​		顶层模块直接与全部子模块建立联系，其调用引擎模块完成电源变化，调用手动行驶模块、半自动行驶模块和自动行驶模块在对应行驶模式下操作小车。其根据手动行驶模块、半自动行驶模块和自动行驶模块的返回状态更新小车行驶状态，状态更新代码如下所示。

![image-20230108005820864](https://s2.loli.net/2023/01/08/A4Vdry7EUvfGRYS.png)

​		其中next_state1和next_moving_state1，next_state2和next_moving_state2，next_state3和next_moving_state3分别作为输出参数传给手动行驶模块、半自动行驶模块、自动行驶模块用于指示小车下一时刻行驶状态。

#### 4.2、引擎模块

​		引擎模块的输入输出端口如下图所示。

![image-20230107222747411](https://s2.loli.net/2023/01/07/iZYMP4ypTOgQULs.png)

```
input[1:0] global_state 小车全局行驶模式（手动、半自动、自动），标识当前小车所处全局行驶模式
input clk 系统时钟信号
input rst 重置信号，由重置按钮发出
input power_on 电源开启信号，由电源开启按钮发出，长按一秒以上小车电源开启
input power_off 电源关闭信号，由电源关闭按钮发出，当信号处于高电平时小车电源关闭
input manual_power 手动模式传入的电源状态，若手动模式发出电源熄火状态，小车全局电源关闭
output next_power 指示下一时刻电源状态
output power_light 根据小车电源是否开启判断是否亮起电源指示灯
```

​		引擎模块实现了判断小车电源状态功能。引擎模块使用顶层模块传入的时钟信号，调用分频器子模块获取不同频率的时钟信号。根据传入的电源开启、关闭按钮的信号，小车对电源状态进行判断：电源开启按钮按下一秒以上时，引擎模块中输出next_power指示电源开启状态，输出power_light电源指示灯处于亮起状态；小车关闭按钮按下时，输出next_power指示电源关闭状态，输出power_light电源指示灯处于熄灭状态。manual_power指示手动模式下小车电源应处于的状态，此时输出next_power和power_light直接和manual_power相关。

#### 4.3、手动行驶模块

​		手动行驶模块的输入输出端口如下图所示。

![image-20230107233628459](https://s2.loli.net/2023/01/07/b85yRdIZrVcu6kU.png)

```
input clk 系统时钟信号
input rst 重置信号，由重置按钮发出
input power 小车电源信号，由顶层模块传入
input[1:0] global_state 小车全局行驶模式（手动、半自动、自动），标识当前小车所处全局行驶模式
input[1:0] state 小车对于当前行驶模式下的状态
input[3:0] moving_state 小车对于当前行驶模式下的行驶状态，传入给UART模块操纵小车行驶
input clutch 离合器，关联离合器开关
input brake 刹车，关联刹车开关
input throttle 油门，关联油门开关
input rgs 倒车，关联倒车开关
input left 左转，关联左转开关
input right 右转，关联右转开关
output[1:0] next_state 小车对于当前行驶模式下的下一时刻状态
output[3:0] next_moving_state 小车对于当前行驶模式下的下一时刻行驶状态
output manual_power 手动模式对电源的影响，若小车熄火应返回关闭小车电源，与引擎模块相关联
output turn_left_light 小车左转向灯，左转时亮起
output turn_right_light 小车右转向灯，右转时亮起
output[7:0] seg1 七段数码显示管输出
output[7:0] seg2 七段数码显示管输出
output[7:0] an 七段数码显示管输出
```

​		手动行驶模块主要对小车在手动行驶模式下的行为逻辑和状态机变化进行实现。当小车处于电源开启状态且全局行驶模式为手动模式时，小车进行手动模式下的状态机变化，在手动模式下共有三种状态，状态转化关系已在框图中展现。离合器、刹车、油门、倒车、左转、右转对应操作均有可能对小车行驶状态产生影响，当小车行驶状态变化时会对应输出下一时刻状态next_state和next_moving_state。当小车左转或右转操作时，对应的输出turn_left_light或turn_right_light会亮起。seg1、seg2和an均作为里程表模块的输出。

#### 4.4、里程表模块

​		里程表模块的输入输出端口如下图所示。

![image-20230108011358223](https://s2.loli.net/2023/01/08/28CBkrwspZoPQ5q.png)

```
input clk 系统时钟信号
input rst 重置信号，由重置按钮发出
input moving 小车行驶状态，由手动行驶模块传入
input activate 里程表是否激活，在手动行驶模块判断
output[7:0] seg1 七段数码显示管输出
output[7:0] seg2 七段数码显示管输出
output[7:0] an 七段数码显示管输出
```

​		里程表模块接收从手动行驶模块传入的moving和activate，当moving为向前行驶或向后行驶且activate为1'b1（小车电源开启且处于手动行驶模式）时修改输出seg1，seg2和an的值，使得七段数码显示管上里程表计数器匀速增加。

#### 4.5、半自动行驶模块

​		半自动行驶模块的输入输出端口如下图所示。

![image-20230108011322086](https://s2.loli.net/2023/01/08/fpR71z86oBMsqaJ.png)

```
input power 小车电源信号，由顶层模块传入
input[1:0] global_state 小车全局行驶模式（手动、半自动、自动），标识当前小车所处全局行驶模式
input[3:0] detector UART模块检测到的障碍信号
input[1:0] state 小车对于当前行驶模式下的状态
input[3:0] moving_state 小车对于当前行驶模式下的行驶状态，传入给UART模块操纵小车行驶
input rst 重置信号，由重置按钮发出
input sys_clk 系统时钟信号
input left 小车在等待时发出的左转指令
input right 小车在等待时发出的右转指令
input straight 小车在等待时发出的前进指令
input back 小车在等待时发出的调头指令
output[1:0] next_state 小车对于当前行驶模式下的下一时刻状态
output[3:0] next_moving_state 小车对于当前行驶模式下的下一时刻行驶状态
```

​		半自动行驶模块主要对小车在半自动行驶模式下的行为逻辑和状态机变化进行实现。小车处于电源开启状态且全局行驶模式为半自动模式时，小车进行半自动模式下的状态机变化，在半自动模式下共有四种状态，状态转化关系已在框图中展现。当小车不处于等待状态时，操作左转、右转、前进、调头等开关均不会对小车当前行驶状态产生影响；当小车处于冷却状态下时，小车会向前行驶并在时间到达阈值后进入向前行驶状态，本操作是为了小车能够行驶出岔口，小车直接在向前行驶状态时会实时检测是否在岔路口中；当小车处于转向状态时，小车会监听时序逻辑控制的转向时间，当转向时间到达阈值时小车会进入冷却状态向前行驶；当小车处于向前行驶状态时，小车会通过detector监控是否到达岔路口，若到达岔路口则小车停下进入等待指令状态。小车对应的状态改变都会修改next_state和next_moving_state来正确表示小车下一时刻的行驶状态。

#### 4.6、自动行驶模块

​		自动行驶模块的输入输出端口如下图所示。

![image-20230108142929132](https://s2.loli.net/2023/01/08/2hg6CJqSPT89Ilf.png)

```
input sys_clk 系统时钟信号
input rst 重置信号，由重置按钮发出
input power 小车电源信号，由顶层模块传入
input global_state 小车全局行驶模式（手动、半自动、自动），标识当前小车所处全局行驶模式
input[1:0] state 小车对于当前行驶模式下的状态
input[3:0] moving_state 小车对于当前行驶模式下的行驶状态，传入给UART模块操纵小车行驶
input[3:0] detector UART模块检测到的障碍信号
output pl_beacon_sig 放置障碍信号
output de_beacon_sig 清除障碍信号
output[1:0] next_state 小车对于当前行驶模式下的下一时刻状态
output[3:0] next_moving_state 小车对于当前行驶模式下的下一时刻行驶状态
```

​		自动行驶模块主要对小车在自动行驶模式下的行为逻辑和状态机变化进行实现。小车处于电源开启状态且全局行驶模式为自动模式时，小车进行自动模式下的状态机变化，在自动模式下共有四种状态，状态转化关系已在框图中展现。当小车处于等待状态时其会进行一定的时间缓冲，之后会根据detector检测的障碍信号进行小车下一状态的变化为冷却状态或转向状态；当小车处于冷却状态时，小车会冷却指定时间使得小车能够成功驶出岔口，此时小车会进入到向前行驶状态；当小车处于向前行驶状态时，其会根据detector的检测信号是否停下进行下一状态的判断，若要停下小车会进入等待状态，未停下小车则继续保持向前行驶状态；当小车处于转向状态时，小车会转向90°后进入冷却状态。小车对应的状态改变都会修改next_state和next_moving_state来正确表示小车下一时刻的行驶状态。

BUG：经测试，小车在自动模式下到达岔路口后无法正确做出左转操作，本该进行左转的地方都进行了右转操作。

原因分析：经过认真检查小车状态机改变逻辑与小车转向方向判断代码，我们发现代码逻辑部分并未出现错误。故推断我们的BUG可能由硬件电路设计出现差错或开发板存在问题导致。
