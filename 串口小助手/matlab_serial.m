x = 0:2*pi/9:2*pi;
sin_y = sin(x);
signal = [0 0 1 1 1 1 1 1 1 1];
%% 读取图像
picID = fopen('noisy_cat_web.txt');
pic = textscan(picID,'%f','Delimiter',',');
pic = cell2mat(pic);
pic = pic';
%%
f = single(pic); %转化为单精度
f_tx = typecast(f,'uint8');
%%
%只做了简单的将每一个单精度浮点数划分成4个bytes后倒序存放的操作，没有做其他改变，可以看作从小端开始传输数据
S = serialport("COM4",115200,"Parity","none","DataBits",8,"StopBits",1);
configureTerminator(S,"CR/LF");  %设置终止符CR/LF
configureCallback(S,"terminator",@readSerialData);
% for i = 1:10
%     write(S,[1],'uint8');
%     pause(0.2);
% end
while 1
    pause(0.5);
    length = size(f_tx,2);
    for i=1:length
        write(S,f_tx(i),'uint8');  % f + 终止符 
        pause(0.0001);
    end
end
%delete(S)

% 回调函数
function readSerialData(src,~)
   data = readline(src)
   src.UserData = data;
end