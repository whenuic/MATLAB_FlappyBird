function varargout = FB2(varargin)
% FB2 M-file for FB2.fig
%      FB2, by itself, creates a new FB2 or raises the existing
%      singleton*.
%
%      H = FB2 returns the handle to a new FB2 or the handle to
%      the existing singleton*.
%
%      FB2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FB2.M with the given input arguments.
%
%      FB2('Property','Value',...) creates a new FB2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FB2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FB2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FB2

% Last Modified by GUIDE v2.5 06-Jan-2018 22:40:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FB2_OpeningFcn, ...
                   'gui_OutputFcn',  @FB2_OutputFcn, ...
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


% --- Executes just before FB2 is made visible.
function FB2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FB2 (see VARARGIN)

% Choose default command line output for FB2
handles.output = hObject;

handles.picXLength = 200; % total "pixels" of the game displayed board
handles.c_busy=40; % length of a gate in x direction;
handles.c_empty=64; % length between gates in x
handles.p=1/60; % refresh frequency
handles.maxgap=0.3; % maximum height change between neighboring gate;
handles.gap=0.4; % height of gate
handles.lowbound=0.1; % gate should be at least 0.1 from ground; 
handles.highbound=0.9; % gate should be no higher than 0.9;
handles.low_last=handles.lowbound;
handles.birdYPos=0.8; %y coordinate of the bird
handles.birdXPos = 67;
handles.uptime=0; %uptime=count how many steps the input energy is left
handles.g=0.00010; %g=gravity constant; v=velocity
handles.v=0;
handles.upseries=0.012*ones(12);
handles.pauseflag=1; %pauseflag=1, pause; pauseflag=else, resume
handles.t=0; %t=total internal time since start
handles.isGameOver = false;

% gates parameters
lowmin=max(handles.low_last-handles.maxgap,handles.lowbound);
lowmax=min(handles.low_last+handles.maxgap,handles.highbound-handles.gap);
g1low = (lowmax-lowmin)*rand+lowmin;
g1high = g1low + handles.gap;
handles.g1 = [177/handles.picXLength, g1low, g1high];% x, leftlow, lefthigh;
handles.low_last = g1low;

lowmin=max(handles.low_last-handles.maxgap,handles.lowbound);
lowmax=min(handles.low_last+handles.maxgap,handles.highbound-handles.gap);
g2low = (lowmax-lowmin)*rand+lowmin;
g2high = g2low + handles.gap;
handles.g2 = [(177+handles.c_busy+handles.c_empty)/handles.picXLength, g2low, g2high];% x, leftlow, lefthigh;
handles.low_last = g2low;

lowmin=max(handles.low_last-handles.maxgap,handles.lowbound);
lowmax=min(handles.low_last+handles.maxgap,handles.highbound-handles.gap);
g3low = (lowmax-lowmin)*rand+lowmin;
g3high = g3low + handles.gap;
handles.g3 = [(177+2*handles.c_busy+2*handles.c_empty)/handles.picXLength, g3low, g3high];% x, leftlow, lefthigh;
handles.low_last = g3low;

% gates handles
set(handles.pic0, 'NextPlot', 'add');
handles.gates = gateClass(handles.pic0, handles.gap, g1low, handles.c_busy, handles.picXLength, 177);
handles.gates(end+1) = gateClass(handles.pic0, handles.gap, g2low, handles.c_busy, handles.picXLength, 177+handles.c_busy+handles.c_empty);
handles.gates(end+1) = gateClass(handles.pic0, handles.gap, g3low, handles.c_busy, handles.picXLength, 177+2*handles.c_busy+2*handles.c_empty);

handles.birdHandle = plot(handles.pic0, handles.birdXPos/handles.picXLength, handles.birdYPos, 'ro'); hold on;

pause(0.1);
handles.ht=timer;
set(handles.ht,'ExecutionMode','FixedRate');
set(handles.ht,'Period',handles.p);
set(handles.ht,'TimerFcn', {@draw, hObject});

set(handles.pic0, 'XLim', [0 1]);
set(handles.pic0,'YLim',[0 1]);

% Update handles structure
guidata(hObject, handles);
start(handles.ht);

% UIWAIT makes FB2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FB2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
pause(2);

function draw(~,~,hO)
handles = guidata(hO);

gOver = false;
if handles.birdXPos > handles.gates(1).getXLeft() && handles.birdXPos < handles.gates(1).getXRight()
    if handles.birdYPos < handles.gates(1).getYLow() || handles.birdYPos > handles.gates(1).getYHigh()
        gOver = true;
    end
elseif handles.birdXPos > handles.gates(2).getXLeft() && handles.birdXPos < handles.gates(2).getXRight()
    if handles.birdYPos < handles.gates(2).getYLow() || handles.birdYPos > handles.gates(2).getYHigh()
        gOver = true;
    end
elseif handles.birdXPos > handles.gates(3).getXLeft() && handles.birdXPos < handles.gates(3).getXRight()
    if handles.birdYPos < handles.gates(3).getYLow() || handles.birdYPos > handles.gates(3).getYHigh()
        gOver = true;
    end
else
    if handles.birdYPos < 0 || handles.birdYPos > 1
        gOver = true;
    end
end
if gOver == true
    set(handles.display2, 'String', 'GAME OVER', 'FontSize', 20);
    handles.pauseflag=1;
    stop(handles.ht);
    handles.isGameOver = true;
end

if handles.pauseflag==0
    handles.t=handles.t+1;
    if handles.t>177
        set(handles.display, 'String', floor((handles.t-177)/(handles.c_busy+handles.c_empty))+1,'FontSize',20);%display how many gates are passed
    end

handles.gates(1).stepLeft();
handles.gates(2).stepLeft();
handles.gates(3).stepLeft();

delta = handles.c_busy+handles.c_empty;
if handles.gates(1).getXRight() < 0
    handles.gates(1).setXPos(handles.gates(3).getXLeft()+delta);
    
    lowmin=max(handles.low_last-handles.maxgap,handles.lowbound);
    lowmax=min(handles.low_last+handles.maxgap,handles.highbound-handles.gap);
    g1low = (lowmax-lowmin)*rand+lowmin;
    
    handles.gates(1).setYLevel(g1low);
end

if handles.gates(2).getXRight() < 0
    handles.gates(2).setXPos(handles.gates(1).getXLeft()+delta);

    lowmin=max(handles.low_last-handles.maxgap,handles.lowbound);
    lowmax=min(handles.low_last+handles.maxgap,handles.highbound-handles.gap);
    g2low = (lowmax-lowmin)*rand+lowmin;
    
    handles.gates(2).setYLevel(g2low);
end

if handles.gates(3).getXRight() < 0
    handles.gates(3).setXPos(handles.gates(2).getXLeft()+delta);
    
    lowmin=max(handles.low_last-handles.maxgap,handles.lowbound);
    lowmax=min(handles.low_last+handles.maxgap,handles.highbound-handles.gap);
    g3low = (lowmax-lowmin)*rand+lowmin;

    handles.gates(3).setYLevel(g3low);
end    

if handles.uptime==0 %whether freely drop or push up? uptime=0, freely drop
         handles.v=handles.v+handles.g; %update dropping velocity
         handles.birdYPos=handles.birdYPos-handles.v;
         handles.birdHandle.YData = handles.birdYPos;
else    
         handles.birdYPos=handles.birdYPos+handles.upseries(handles.uptime);
         handles.birdHandle.YData = handles.birdYPos;
         handles.uptime=handles.uptime-1;
         handles.v=0;
end

end

guidata(hO,handles);


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.pauseflag == 1
    return;
end
handles.uptime=length(handles.upseries);
guidata(hObject.Parent, handles);




% --- Executes on mouse press over axes background.
function pic0_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pic0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.pauseflag == 1
    return;
end
handles.uptime=length(handles.upseries);
guidata(hObject.Parent, handles);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.pauseflag==1
    handles.pauseflag=0;
elseif handles.pauseflag==0
    handles.pauseflag=1;
end
guidata(hObject.Parent, handles);


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% gates parameters
if handles.isGameOver == false
    return;
end

handles.low_last = handles.lowbound;
handles.birdYPos=0.8; %y coordinate of the bird
handles.uptime=0; %uptime=count how many steps the input energy is left
handles.v=0;
handles.pauseflag=1; %pauseflag=1, pause; pauseflag=else, resume
handles.t=0; %t=total internal time since start
handles.isGameOver = false;

set(handles.display2, 'String', '', 'FontSize', 20);
set(handles.display, 'String', '','FontSize',20);%display how many gates are passed

lowmin=max(handles.low_last-handles.maxgap,handles.lowbound);
lowmax=min(handles.low_last+handles.maxgap,handles.highbound-handles.gap);
g1low = (lowmax-lowmin)*rand+lowmin;
g1high = g1low + handles.gap;
handles.g1 = [177/handles.picXLength, g1low, g1high];% x, leftlow, lefthigh;
handles.low_last = g1low;

lowmin=max(handles.low_last-handles.maxgap,handles.lowbound);
lowmax=min(handles.low_last+handles.maxgap,handles.highbound-handles.gap);
g2low = (lowmax-lowmin)*rand+lowmin;
g2high = g2low + handles.gap;
handles.g2 = [(177+handles.c_busy+handles.c_empty)/handles.picXLength, g2low, g2high];% x, leftlow, lefthigh;
handles.low_last = g2low;

lowmin=max(handles.low_last-handles.maxgap,handles.lowbound);
lowmax=min(handles.low_last+handles.maxgap,handles.highbound-handles.gap);
g3low = (lowmax-lowmin)*rand+lowmin;
g3high = g3low + handles.gap;
handles.g3 = [(177+2*handles.c_busy+2*handles.c_empty)/handles.picXLength, g3low, g3high];% x, leftlow, lefthigh;
handles.low_last = g3low;


% gates handles
delete(handles.gates(1));
delete(handles.gates(2));
delete(handles.gates(3));

delete(handles.birdHandle);

set(handles.pic0, 'NextPlot', 'add');
handles.gates = gateClass(handles.pic0, handles.gap, g1low, handles.c_busy, handles.picXLength, 177);
handles.gates(end+1) = gateClass(handles.pic0, handles.gap, g2low, handles.c_busy, handles.picXLength, 177+handles.c_busy+handles.c_empty);
handles.gates(end+1) = gateClass(handles.pic0, handles.gap, g3low, handles.c_busy, handles.picXLength, 177+2*handles.c_busy+2*handles.c_empty);

handles.birdHandle = plot(handles.pic0, handles.birdXPos/handles.picXLength, handles.birdYPos, 'ro'); hold on;

set(handles.pic0, 'XLim', [0 1]);
set(handles.pic0,'YLim',[0 1]);

guidata(hObject.Parent, handles);
start(handles.ht);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if ~isempty(handles.ht)
    stop(handles.ht);
    delete(handles.ht);
end
delete(hObject);
