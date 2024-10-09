function varargout = untitled1(varargin)
% UNTITLED1 M-file for untitled1.fig
%      UNTITLED1, by itself, creates a new UNTITLED1 or raises the existing
%      singleton*.
%
%      H = UNTITLED1 returns the handle to a new UNTITLED1 or the handle to
%      the existing singleton*.
%
%      UNTITLED1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UNTITLED1.M with the given input arguments.
%
%      UNTITLED1('Property','Value',...) creates a new UNTITLED1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before untitled1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to untitled1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help untitled1

% Last Modified by GUIDE v2.5 28-Mar-2014 14:23:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @untitled1_OpeningFcn, ...
                   'gui_OutputFcn',  @untitled1_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
 
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before untitled1 is made visible.
function untitled1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to untitled1 (see VARARGIN)

% Choose default command line output for untitled1
handles.output = hObject;

global x gap maxgap p low_last position
global uptime v g upseries pauseflag t
%T_busy and T_empty counts how many steps being used to generate gate or space
%x=sampling points in x direction;
%c_busy=length of a gate in x direction; c_empty=length between gates in x
%direction
%low=lower boundary; high=higher boundary;
%p=1/frame rate;
%maxgap=maximum height change between neighboring gate; gap=height of gate
%lowbound=gate should be at least 0.1 from ground; highbound=gate should be
%no higher than 0.9;
%low_last
%position=y coordinate of the bird
%uptime=count how many steps the input energy is left
%g=gravity constant; v=velocity
%upseries=[0.15 0.07 0.02];
%pauseflag=1, pause; pauseflag=else, resume
%t=total internal time since start

handles.T_busy = 0; 
handles.T_empty = 0;
handles.busy=1;%busy==1, generates gates
handles.c_busy=40; handles.c_empty=64; p=1/60;
maxgap=0.3; gap=0.4; handles.lowbound=0.1; handles.highbound=0.9;
x=0:0.005:1;
handles.low=zeros(1,length(x));
low_last=handles.low(1);
handles.high=ones(1,length(x));
position=0.8;
uptime=0;
g=0.00010; v=0;
upseries=0.012*ones(12);
pauseflag=1;
t=0;

pause(0.1);
handles.ht=timer;
set(handles.ht,'ExecutionMode','FixedRate');
set(handles.ht,'Period',p);
set(handles.ht,'TimerFcn', {@draw, hObject});
start(handles.ht);

stairs(handles.pic0, x,handles.low);
set(handles.pic0,'NextPlot','add');
stairs(handles.pic0, x,handles.high);
set(handles.pic0,'NextPlot','replace');
set(handles.pic0,'YLim',[0 1]);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes untitled1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = untitled1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
pause(2);

function draw(~,~,hO)
global x gap maxgap p low_last position
global uptime v g upseries pauseflag t
handles = guidata(hO);
if position<handles.high(67)&&position>handles.low(67)
else
    set(handles.display2, 'String', 'GAME OVER', 'FontSize', 20);
    pauseflag=1;
    delete(handles.ht);
end

if pauseflag==0
    t=t+1;
    if t>177
        set(handles.display, 'String', floor((t-177)/(handles.c_busy+handles.c_empty))+1,'FontSize',20);%display how many gates are passed
    end    
    if handles.busy==1;
        if mod(handles.T_busy,handles.c_busy)==0
            lowmin=max(low_last-maxgap,handles.lowbound);
        	lowmax=min(low_last+maxgap,handles.highbound-gap);
        
            handles.low(1:length(handles.low)-1)=handles.low(2:end);
            handles.high(1:length(handles.high)-1)=handles.high(2:end);
            handles.low(end)=(lowmax-lowmin)*rand+lowmin;
            handles.high(end)=handles.low(end)+gap;
        else
            handles.low(1:length(handles.low)-1)=handles.low(2:end);
            handles.high(1:length(handles.high)-1)=handles.high(2:end);
            handles.low(end)=handles.low(end-1);
            handles.high(end)=handles.low(end)+gap;
        end

        stairs(handles.pic0, x,handles.low);
        set(handles.pic0,'NextPlot','add');
        stairs(handles.pic0, x,handles.high);
        %set(handles.pic0,'NextPlot','replace');
        set(handles.pic0,'YLim',[0 1]);
        handles.T_busy = handles.T_busy+1;
        if mod(handles.T_busy,handles.c_busy)==0
            handles.busy=0;low_last=handles.low(end);
        end
    else
        handles.low(1:length(handles.low)-1)=handles.low(2:end);
        handles.high(1:length(handles.high)-1)=handles.high(2:end);
        handles.low(end)=0;
        handles.high(end)=1;
        stairs(handles.pic0, x,handles.low);
        set(handles.pic0,'NextPlot','add');
        stairs(handles.pic0, x,handles.high);
        %set(handles.pic0,'NextPlot','replace');
        set(handles.pic0,'YLim',[0 1]);
        handles.T_empty=handles.T_empty+1;
        if mod(handles.T_empty,handles.c_empty)==0
            handles.busy=1;
        end
    end
    if uptime==0 %whether freely drop or push up? uptime=0, freely drop
        v=v+g; %update dropping velocity
        position=position-v;
        plot(handles.pic0,round(length(x)/3)/length(x),position,'ro');
    else    
        position=position+upseries(uptime);
        plot(handles.pic0,round(length(x)/3)/length(x),position,'ro');
        uptime=uptime-1;
        v=0;
    end
    set(handles.pic0,'NextPlot','replace');

end
guidata(hO,handles);


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global uptime upseries
uptime=length(upseries);




% --- Executes on mouse press over axes background.
function pic0_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pic0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global pauseflag
if pauseflag==1
    pauseflag=0;
elseif pauseflag==0
    pauseflag=1;
end
