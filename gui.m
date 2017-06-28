function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 31-May-2017 17:43:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
handles.isVid = 0;
handles.isImg = 0;
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
warning('off','all')
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
run vlfeat/toolbox/vl_setup;

run(fullfile('matconvnet','matlab','vl_setupnn.m'));
handles.output = hObject;

in = load('var/max.mat');
handles.max =  in.max;

in = load('var/classifier.mat');
handles.classifierModel = in.classifierModel;

in = load('var/w.mat');
handles.w = in.w;


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in loadImage.
function loadImage_Callback(hObject, eventdata, handles)
% hObject    handle to loadImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Types of files the dialogue should be able to open
FilterSpec                              = {'*.bmp;*.cur;*.fts;*.fits;*.gif;*.hdf;*.ico;*.j2c;*.j2k;*.jp2;*.jpf;*.jpx;*.jpg;*.jpeg;*.pbm;*.pcx;*.pgm;*.png;*.pnm;*.ppm;*.ras;*.tif;*.tiff;*.xwd','All Images'};
% File details
[FileName, FilePath, OGFilter]          = uigetfile(FilterSpec,'Please select an image');
% Create string of file name
FilePointer         = strcat(FilePath,FileName);
handles.FilePointer = FilePointer;
% Read image from file
OrigImage           = imread(FilePointer);
% Store image in figure handle
handles.OrigImage   = OrigImage;
handles.isVid = 0;
handles.isImg = 1;
guidata(hObject, handles);
% Show image in left hand axes
imshow(OrigImage,'Parent',handles.axes1);

% --- Executes on button press in detectPedestrians.
function detectPedestrians_Callback(hObject, eventdata, handles)
% hObject    handle to detectPedestrians (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.isImg == 1
    im = handles.OrigImage;
    t = identify_pedestrians(handles.OrigImage,handles.classifierModel,handles.w,handles.max);
    t = round(t,4);
    set(handles.dTime,'FontSize',12);
    set(handles.dTime, 'string', t)
else 
    OrigVid = handles.OrigVid;
    numFrames = OrigVid.NumberOfFrames;
    for i=100:5:numFrames
        im = read(OrigVid,i);
        imshow(im,'Parent',handles.axes1);
        hold on;
        t = identify_pedestrians(im,handles.classifierModel,handles.w,handles.max);
        t = round(t,4);
        set(handles.dTime,'FontSize',12);
        set(handles.dTime, 'string', t)
        hold off;
        pause(0.000001)

    end
end


% --- Executes on button press in loadVideo.
function loadVideo_Callback(hObject, eventdata, handles)
% hObject    handle to loadVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FilterSpec                              = {'*.avi;*.mp4','All videos'};
[FileName, FilePath, OGFilter]          = uigetfile(FilterSpec,'Please select a video');
% Create string of file name
FilePointer         = strcat(FilePath,FileName);
handles.FilePointer = FilePointer;
% Read video from file
OrigVid = VideoReader(FilePointer);
% Store video in figure handle
handles.OrigVid   = OrigVid;
handles.isVid = 1;
handles.isImg = 0;
guidata(hObject, handles);
% Show image in left hand axes
imshow(read(OrigVid,1),'Parent',handles.axes1);
