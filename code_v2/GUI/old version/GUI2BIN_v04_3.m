function [] = GUI2BIN_v04_3()
%% Adapter to analyze aggregates
clc;clear
% Questions? Ask Luc or Bin
version_name = mfilename;

%% SET DEFAULT DATAPATHS
computername = getenv('COMPUTERNAME');
% % % % % % % % % ADD YOUR COMPUTER TO THIS % % % % % %
switch computername
    case 'BIGTREE'
    defaults_imagedata_path = 'D:\Bin\gui_test\'; %global variable, has to be put in function as a static variable
    defaults_functions_path = 'D:\code\';

    case 'HOOKE'
    defaults_imagedata_path = 'D:\LEW_ASAP_Data_TEMP\data\';
    % This is where your GITHUB Brain-imaging folder is selected
    defaults_functions_path = 'D:\Github\Brain-imaging\Brain-imaging\code\';
end
% % END OF USER SELECTED FOLDERS % % % % %

defaults_configurations_path = [defaults_functions_path,'config\']; %not pass into the callback functions (excecutable function called in another function), so not a global var

%% Add paths for functions
addpath(genpath(defaults_functions_path));
import analyze.* image.* load.* process.* spatial.* visual.*

%% SECTION 1: Set up GUI PANELS
MAIN_FIGURE = figure(55);
clf;
warning('off','all');
set(0, 'DefaultUIControlFontSize', 10);

set(MAIN_FIGURE,'units','pixels','position',[100 200 800 500],'Color',[1 1 1]);
set(0,'defaultuicontrolunits','normalized');
% Header information
program_version = uicontrol('style','text','position',[.00 .95 .25 .05],'string', version_name,'BackgroundColor',[1 1 1]);
program_title   = uicontrol('style','text','position',[.25 .95 .50 .05],'string', 'Your Oligomer Pipeline Interface','BackgroundColor',[1 1 .5]);
status_title    = uicontrol('style','text','position',[.75 .95 .25 .05],'string', 'Not running','BackgroundColor',[.5 1 .5]); %global variable

% Here are the four panels
Configuration_panel = uipanel('parent',MAIN_FIGURE,'Title','Configuration','BackgroundColor','white','Position',[0.00 0.00 .25 .95]);
Preprocessing_panel = uipanel('parent',MAIN_FIGURE,'Title','Preprocessing','BackgroundColor','white','Position',[0.25 0.00 .25 .95]);
Analysis_panel      = uipanel('parent',MAIN_FIGURE,'Title','Analysis',     'BackgroundColor','white','Position',[0.50 0.00 .25 .95]);
Formatting_panel    = uipanel('parent',MAIN_FIGURE,'Title','Formatting',     'BackgroundColor','white','Position',[0.75 0.00 .25 .95]);

%% SECTION 2: CONFIGURATION PANEL
% set path
selection_configuration_folder = uicontrol('parent',Configuration_panel,'style','togglebutton','position', [.00  .90 1.0 .05],'string',defaults_configurations_path,'Value',0,'callback',{@Directory_select,'Configurations_folder'}); %an uicontrol object

% find and set available configs
uicontrol('parent',Configuration_panel,'style','text','position',[0  .95 1 .05],'string','Configurations folder');
uicontrol('parent',Configuration_panel,'style','text','position',[00  .80 1.0 .05],'string','Oligomer detection');

%list of config
selection_configuration_ol   = uicontrol('parent',Configuration_panel,'style','popupmenu','position', [.00  .75 1.0 .05],'string',{''},'callback',{@Display_configuration,'olig'}); %drag section to find config
uicontrol('parent',Configuration_panel,'style','text','position',[00  .70 1 .05],'string','Large object detection');
selection_configuration_lb   = uicontrol('parent',Configuration_panel,'style','popupmenu','position', [.00  .65 1.0 .05],'string',{''},'callback',{@Display_configuration,'lb'});
uicontrol('parent',Configuration_panel,'style','text','position',[00  .60 1 .05],'string','Cell detection');
selection_configuration_cell = uicontrol('parent',Configuration_panel,'style','popupmenu','position', [.00  .55 1.0 .05],'string',{''},'callback',{@Display_configuration,'cell'});

selection_configuration_folder = uicontrol('parent',Configuration_panel,'style','togglebutton','position', [.00  .90 1.0 .05],'string',defaults_configurations_path,'Value',0,'callback',{@Directory_select,'Configurations_folder'});     
configuration_options = dir([defaults_configurations_path '\*json']);
selection_configuration_ol.String = {configuration_options.name};
selection_configuration_lb.String = {configuration_options.name};
selection_configuration_cell.String = {configuration_options.name};

% display config
% conf is a struct containing several uicontrol objects. each object has a string field the same as config(s)

% Channel
uicontrol('parent',Configuration_panel,'style','text','position',[0  .45 .75 .05],'string','Aggregate channel');
conf.channel_agg = uicontrol('parent',Configuration_panel,'style','text','position',[.75  .45 .25 .05]); %add position info to the uicontrol object

% Channel
uicontrol('parent',Configuration_panel,'style','text','position',[0  .40 .75 .05],'string','Cell channel');
conf.channel_cell = uicontrol('parent',Configuration_panel,'style','text','position',[.75  .40 .25 .05]);

uicontrol('parent',Configuration_panel,'style','text','position',[0  .3 1 .05],'string','Last configuration selected');
% Width
uicontrol('parent',Configuration_panel,'style','text','position',[0  .25 .5 .05],'string','width');
conf.width = uicontrol('parent',Configuration_panel,'style','text','position',[.5  .25 .5 .05]);
% Height
uicontrol('parent',Configuration_panel,'style','text','position',[0  .20 .5 .05],'string','height');
conf.height = uicontrol('parent',Configuration_panel,'style','text','position',[.5  .20 .5 .05]);
% Frames
uicontrol('parent',Configuration_panel,'style','text','position',[0  .15 .5 .05],'string','frames','fontsize',10);
conf.frames = uicontrol('parent',Configuration_panel,'style','text','position',[.5  .15 .5 .05]);
% Slices
uicontrol('parent',Configuration_panel,'style','text','position',[0  .10 .5 .05],'string','z slices');
conf.slices = uicontrol('parent',Configuration_panel,'style','text','position',[.5  .10 .5 .05]);
% Color
uicontrol('parent',Configuration_panel,'style','text','position',[0  .05 .5 .05],'string','colour');
conf.colour = uicontrol('parent',Configuration_panel,'style','text','position',[.5  .05 .5 .05]);

% This does not work yet.
save_configuration_button = uicontrol('parent',Configuration_panel,'style','pushbutton','position', [.00 .00 1 .05],'string','save configuration','callback',{@SAVE_CONFIGURATION}); %#ok<NASGU> 

%% SECTION 3: PREPROCESSING and FOCUS CHECKING
uicontrol('parent',Preprocessing_panel,'style','text','position', [.00  .95 1.0 .05],'string','Raw data location');     
% path of the main folder
selection_preprocessing_folder = uicontrol('parent',Preprocessing_panel,'style','togglebutton','position', [.00  .9 1.0 .05],'string',defaults_imagedata_path,'Value',0,'callback',{@Directory_select,'Preprocessing_folder'});     
uicontrol('parent',Preprocessing_panel,'style','text','position', [.00  .75 1.0 .15],'string','Select the directory containing round folders. subdir: \Round\Sample\Sample_position');     

% Type of focus selection
uicontrol('parent',Preprocessing_panel,'style','text','position', [.00  .45 1.0 .05],'string','Z-plane selection');     
% setting is a struct variable
settings.analysis_group = uibuttongroup('Visible','on','Position',[0 .35 1 .1],'parent',Preprocessing_panel,'SelectionChangedFcn',@slice_selection_method); 
% Create two radio buttons in the button group, two children of analysis_group
settings.analysis1 = uicontrol(settings.analysis_group,'Style','radiobutton','String','Autofocus','Position',[.00  .40 1.0 .5],'value',1);%,'parent',Analysis_panel);
settings.analysis2 = uicontrol(settings.analysis_group,'Style','radiobutton','String','Manual z-range','Position',[.00  .00 1.0 .5],'value',0);%,'parent',Analysis_panel);

% First frame
uicontrol('parent',Preprocessing_panel,'style','text','position',[0  .30 .5 .05],'units','normalized','string','First Frame','fontsize',10);
settings.firstframe = uicontrol('parent',Preprocessing_panel,'style','text','position',[.5  .30 .5 .05],'units','normalized','string','0','fontsize',10,'callback',{@CHANGE_CONFIGURATION});
% Last Frame
uicontrol('parent',Preprocessing_panel,'style','text','position',[0  .25 .5 .05],'units','normalized','string','Last Frame','fontsize',10);
settings.lastframe = uicontrol('parent',Preprocessing_panel,'style','text','position',[.5  .25 .5 .05],'units','normalized','string','0','fontsize',10,'callback',{@CHANGE_CONFIGURATION});

run_preprocessing_button = uicontrol('parent',Preprocessing_panel,'style','pushbutton','position', [.00 .00 1 .05],'string','preprocess data','callback',{@PREPROCESS_DATA});  %#ok<NASGU>, for slience overwriting

%% SECTION 4: ANALYSIS
uicontrol('parent',Analysis_panel,'style','text','position', [.00  .95 1.0 .05],'string','Metadata location');     
find_backslash = strfind(selection_preprocessing_folder.String,'\');
filepath_metadata = [selection_preprocessing_folder.String(1:find_backslash(end)-1),'_metadata.csv'];
% path of the metadata
selection_metadata_file = uicontrol('parent',Analysis_panel,'style','togglebutton','position', [.00  .9 1.0 .05],'string',filepath_metadata,'Value',0,'callback',{@Directory_select,'Metadata_file'}); %value 0 and 1 only changes the block colour     

% Type of analysis
uicontrol('parent',Analysis_panel,'style','text','position', [.00  .8 1.0 .05],'string','Analysis method');     
settings.oligomer_analysis = uicontrol('parent',Analysis_panel,'style','checkbox','position',[0  .75 1 .05],'string','Oligomer','value',1);
settings.cell_analysis = uicontrol('parent',Analysis_panel,'style','checkbox','position',[0  .70 1 .05],'string','Cell analysis','value',0);
   
% Type of analysis
settings.save = uicontrol('parent',Analysis_panel,'style','checkbox','position', [.00  .45 1.0 .05],'string','Save data');     
settings.save_oligomer_table = uicontrol('parent',Analysis_panel,'style','checkbox','position',[0  .40 1 .05],'string','Oligomer table','value',1,'HorizontalAlignment','left');
settings.save_oligomer_mask = uicontrol('parent',Analysis_panel,'style','text','position',[0  .35 1 .05],'string','    Oligomer mask','value',0,'HorizontalAlignment','left');
settings.save_Large_aggregate_table = uicontrol('parent',Analysis_panel,'style','checkbox','position',[0  .30 1 .05],'string','Large-aggregate table','value',1,'HorizontalAlignment','left');
settings.save_Large_aggregate_mask = uicontrol('parent',Analysis_panel,'style','text','position',[0  .25 1 .05],'string','    Large-aggregate mask','value',0,'HorizontalAlignment','left');
settings.save_cell_table = uicontrol('parent',Analysis_panel,'style','checkbox','position',[0  .20 1 .05],'string','Cell table','value',0,'HorizontalAlignment','left');

run_analysis_button = uicontrol('parent',Analysis_panel,'style','pushbutton','position', [.00 .00 1 .05],'string','analyse data','callback',{@ANALYSE_DATA}); %#ok<NASGU> 

%% SECTION 5: OUTPUT and CHANGE FORMAT

uicontrol('parent',Formatting_panel,'style','text','position', [.00  .95 1.0 .05],'string','Result location');     
find_backslash    = strfind(selection_preprocessing_folder.String,'\');
filepath_metadata = [selection_preprocessing_folder.String(1:find_backslash(end)-1),'_result'];
% path of the result folder
selection_result_folder = uicontrol('parent',Formatting_panel,'style','togglebutton','position', [.00  .9 1.0 .05],'string',filepath_metadata,'Value',0,'callback',{@Directory_select,'Result_folder'}); %value 0 and 1 only changes the block colour 

% visualize (unfinish)
% uicontrol('parent',Formatting_panel,'style','text','position', [.00  .8 1.0 .05],'string','visualize');

% Type of output result
uicontrol('parent',Formatting_panel,'style','text','position', [.00  .45 1.0 .05],'string','Result data');
settings.aggre_number = uicontrol('parent',Formatting_panel,'style','checkbox','position', [.00  .40 1.0 .05],'string','Aggregate number','Value',1); 
settings.small_intens = uicontrol('parent',Formatting_panel,'style','checkbox','position', [.00  .35 1.0 .05],'string','Small aggregate intensity','Value',1); 
settings.extra_metadata = uicontrol('parent',Formatting_panel,'style','text','position', [.00  .30 1.0 .05],'string','Include extra metadata','Value',1); 
settings.extra_metadata = uicontrol('parent',Formatting_panel,'style','text','position', [.00  .25 1.0 .05],'string','Note: requires RSID table'); 

run_format_button = uicontrol('parent',Formatting_panel,'style','pushbutton','position', [.00 .00 1 .05],'string','output long format','callback',{@FORMAT_DATA}); 

%% SECTION 6: FUNCTIONS
function Directory_select(~,~,input)
    status_title.String = 'selection';
    status_title.BackgroundColor=[1 .5 .5];
    try
        switch input
            case 'Configurations_folder'
                filepath = uigetdir(defaults_functions_path);
                if filepath(end)~='\'; filepath = [filepath,'\']; end
                selection_configuration_folder.String = filepath;
                selection_configuration_folder.Value = 1;
                configuration_options = dir([filepath '*json']); %all available json files
                selection_configuration_ol.String = {configuration_options.name};
                selection_configuration_lb.String = {configuration_options.name};
                selection_configuration_cell.String = {configuration_options.name};
            case 'Preprocessing_folder'
                filepath = uigetdir(defaults_imagedata_path);
                if filepath(end)~='\'; filepath = [filepath,'\']; end
                selection_preprocessing_folder.String = filepath;
                selection_preprocessing_folder.Value = 1;
            case 'Metadata_file'
                [file, filepath] = uigetfile([defaults_imagedata_path,'*.*']);
                if filepath(end)~='\'; filepath = [filepath,'\']; end
                selection_metadata_file.String = [filepath, file];
                selection_metadata_file.Value = 1;
            case 'Result_folder'
                filepath = uigetdir(defaults_imagedata_path);
                if filepath(end)~='\'; filepath = [filepath,'\']; end
                selection_result_folder.String = filepath;
                selection_result_folder.Value = 1;

        end
    catch
        if (numel(filepath)<=2)
            status_title.String = 'Reselect path';
            return;
        end
    end
    status_title.String='Not running';
    status_title.BackgroundColor=[.5 1 .5];
end

function Display_configuration(self,~,input_field)
    filename = self.String{self.Value};
    filepath = selection_configuration_folder.String;
    s = loadJSON([filepath,filename]);
    conf.channel.String = s.channel;
    conf.width.String  = s.width;
    conf.height.String = s.height;
    conf.frames.String = s.frames;
    conf.slices.String = s.slices;
    conf.colour.String = s.colour;
    switch input_field
        case 'olig'
            conf.channel_agg.String = conf.colour.String;
        case 'lb'
            conf.channel_agg.String = conf.colour.String;
        case 'cell'
            conf.channel_cell.String = conf.colour.String;
    end
end

function SAVE_CONFIGURATION(~,~)
    disp('Option not available yet; select from available configurations');
end

function slice_selection_method(~,~)
    if settings.analysis_group.Children(2).Value %if this is selected (.value==1)
        settings.firstframe.Style = 'text';
        settings.lastframe.Style  = 'text';
    elseif settings.analysis_group.Children(1).Value %two children is added in the following lines
        settings.firstframe.Style = 'edit';
        settings.lastframe.Style  = 'edit';
    end
end

function PREPROCESS_DATA(~,~)
    % This function will create a new directory with the same data; 
    % Then in the original directory, data is time-averaged
    status_title.String = 'Time-averaging data';
    status_title.BackgroundColor = [1 .5 .5];
%     drawnow;

    % Based on main_dataload
    filedir   = selection_preprocessing_folder.String;
    T         = makeMetadata(filedir);
    filenames = T.filenames;
    [filepath,name,~] = fileparts(filenames);
    used      = false(length(filenames),1);
    zi        = str2double(settings.firstframe.String);
    zf        = str2double(settings.lastframe.String);
    z_slice   = []; %[zi zf]
    numImgs   = str2double(conf.frames.String)*str2double(conf.colour.String)*str2double(conf.slices.String);
    movefile(filedir(1:end-1),[filedir(1:end-1),'_raw']); %copy original data to the new folder
    if isempty(T)
        status_title.String = 'Preprocessing failed';
        disp('no tif files found');
        return
    else
        f = waitbar(0,'Compressing data...');
        for i = 1:length(filenames)
            waitbar(i/length(filenames),f,'Compressing data...');

            % This will make the copy
            filename    = strrep(filenames{i},filedir,[filedir(1:end-1),'_raw\']);
            tiff_info   = imfinfo(filename);
            if length(tiff_info) ~= numImgs
                continue
            else
                used(i) = true;
                tmpt = makeDir(filepath{i});
                % This will flatten the image
                s    = loadJSON([selection_configuration_folder.String, selection_configuration_ol.String{selection_configuration_ol.Value}]);
                img  = load.loadImage(filename,s);
                img  = squeeze(mean(img,4));%xyzc
                tmpt = img;
                img  = cat(3,img(:,:,:,1),img(:,:,:,2));
                Tifwrite(uint16(img),fullfile(filepath{i},[name{i},'.tif']));
                if zi ~= 0
                    z_slice = [z_slice;[zi,zf]];
                else
                    z_focus = autoFocusChecking(tmpt(:,:,:,1));
                    z_slice = [z_slice;z_focus];
                end
            end
        end
        close(f)
    end
    T         = T(used,:);
    num_slash = strfind(filedir,'\');
    prefix    = filedir(num_slash(end-1)+1:num_slash(end)-1);
    filename_metadata = [filedir(1:num_slash(end-1)),prefix,'_metadata.csv'];
    T.zi = z_slice(:,1);
    T.zf = z_slice(:,2);
    writetable(T,filename_metadata);
%     selection_metadata_file.String = filename_metadata;
    %     if any(status == 0) 
    %         status_title.String='Preprocessing failed';
    %     else
    status_title.String = 'Not running';
    status_title.BackgroundColor = [.5 1 .5];
end

function ANALYSE_DATA(~,~)
    status_title.String = 'Processing data';
    status_title.BackgroundColor = [1 .5 .5];
%     drawnow;

%   Based on main_cell & main_aggregate
    try
        [filenames,filepath,zs,rsid] = loadMeta(selection_metadata_file.String);
    catch
        disp('Select the correct metadata.csv file');
        status_title.String = 'metadata not found.';
        status_title.BackgroundColor = [1 1 .5];
        return;
    end

    filedir = selection_preprocessing_folder.String;
    s1 = loadJSON(selection_configuration_lb.String{selection_configuration_lb.Value}); %lb
    s2 = loadJSON(selection_configuration_ol.String{selection_configuration_ol.Value}); %oligomer
    s  = loadJSON(selection_configuration_cell.String{selection_configuration_cell.Value}); %cell
    f  = waitbar(0,'Segmenting data...');
    for i = 1:length(filenames)
        waitbar(i/numel(filenames),f,'Segmenting data.');
        img_original = Tifread(filenames{i});
        img_original = reshape(img_original,[s1.height,s1.width,s1.slices,s1.colour]);

        % Aggregate analysis
        if settings.oligomer_analysis.Value
%             s1.channel = 2;
            img_agg    = img_original(:,:,zs(i,1):zs(i,2),s1.channel);
            [smallM,largeM,result_oligomer,~] = aggregateDetection(img_agg,s1,s2,zs(i,1),settings.save.Value); %aggregate, large and small
%             for j = 1:size(img_agg,3)
%                 zimg = double(imresize(img_agg(:,:,j),4));
%                 figure;imshow(zimg,[]);
%                 f    = plotAll(zimg,largeM(:,:,j),[0.6350 0.0780 0.1840]);
%                        plotBinaryMask(f,smallM(:,:,j),[0.8500 0.3250 0.0980])
%                 pause(0.1);
%             end
%             close all;
        end

        % Cell analysis
        if settings.cell_analysis.Value
            img_cell = img_original(:,:,zs(i,1):zs(i,2),s.channel);
            cellM    = process.cellDetection(img_cell,s); %cell
        end
        
        if settings.save.Value %if data will be saved
            newFolder = makeDir(fullfile([filedir(1:end-1),'_result'],filepath{i}));
            if settings.save_oligomer_table.Value
                writetable(result_oligomer,fullfile(newFolder,'result_small_aggregates_561.csv'));
            end
            if settings.save_Large_aggregate_table.Value
                boundaries = array2table(load.BW2boundary(largeM,zs(i,1)),'VariableNames',{'row','col','z'});
                writetable(boundaries,fullfile(newFolder,'result_large_aggregates_561.csv'));
            end
            if settings.cell_analysis.Value && settings.save_cell_table.Value
                boundaries = array2table(load.BW2boundary(cellM,zs(i,1)),'VariableNames',{'row','col','z'});
                writetable(boundaries,fullfile(newFolder,'cell_result.csv'))
            end
        end
    end
    close(f);
    status_title.String = 'Finished processing data';
    status_title.BackgroundColor = [.5 1 .5];
end

function  FORMAT_DATA(~,~)
    status_title.String = 'Processing result';
    status_title.BackgroundColor = [1 .5 .5];

%   Based on oligomer_analysis
    filedir = selection_preprocessing_folder.String;
    [~,filepath,zs,rsid] = loadMeta(selection_metadata_file.String);
    s = loadJSON(selection_configuration_ol.String{selection_configuration_ol.Value}); %oligomer
    s.width = s.width*4; s.height = s.height*4;

    nums_z   = []; %number per slice
    inten_i  = {}; %intensity per oligomer
    inten_t  = []; %tmpt holder
    f        = waitbar(0,'Formatting result...');
    for i = 1:length(rsid)
        waitbar(i/numel(rsid),f,'Formatting result.');
        % Could be modified to remove overlap...
        [idx,filenames] = load.extractName([selection_result_folder.String,'\',filepath{i}],{'large_aggregates','small_aggregates'});     
        large  = readmatrix(filenames{idx{1}}); %large
        small  = readmatrix(filenames{idx{2}}); %small
    
        smalls = {small};
        larges = {large};
    
        [nums,~,inten_all] = process.generalAnalysis(smalls,larges,zs(i,:),rsid(i),[],s);
        nums_z  = [nums_z;nums];
        inten_t = [inten_t;inten_all];
    end
    close(f);

    for i = 1:size(inten_t,2)
        inten_i{i} = vertcat(inten_t{:,i});
    end

    num_slash = strfind(filedir,'\');
    prefix    = filedir(num_slash(end-1)+1:num_slash(end)-1);
    filename_metadata = [filedir(1:num_slash(end-1)),prefix,'_metadata.csv'];
    
    if settings.aggre_number.Value
        T1 = array2table(nums_z,"VariableNames",{'small_nums','large_nums','rsid'});
        writetable(T1,[filedir(1:num_slash(end-1)),prefix,'_numbers_slice.csv']);
    end

    if settings.small_intens.Value
        T2 = array2table(cell2mat(inten_i),"VariableNames",{'sum_intensity','rsid'});
        writetable(T2,[filedir(1:num_slash(end-1)),prefix,'_intensity_oligomer.csv']);
    end

    status_title.String = 'Finished formating result';
    status_title.BackgroundColor = [.5 1 .5];
end

end