function [] = GUI2BIN_v04()
%% Adapter to analyze aggregates
% Questions? Ask Luc or Bin
version_name = mfilename;

%% SET DEFAULT DATAPATHS
% % % % % % % % % CHANGE ME % % % % % %
% This will be the default image-data folder, have a \ at the end of the path
defaults_imagedata_path = 'D:\LEW_ASAP_Data_TEMP\data\';
% This is where your GITHUB Brain-imaging folder is selected
defaults_functions_path = 'D:\Github\Brain-imaging\Brain-imaging\code\';
% % END OF USER SELECTED FOLDERS % % % % %

defaults_configurations_path = [defaults_functions_path,'config\'];

%% Add paths for functions
addpath(genpath(defaults_functions_path));
import analyze.* image.*  load.* analyze.* process.* spatial.* visual.*

%% SECTION 1: Set up GUI PANELS
MAIN_FIGURE = figure(55);
clf;
warning('off','all');
set(0, 'DefaultUIControlFontSize', 11);

set(MAIN_FIGURE,'units','pixels','position',[100 200 800 500],'Color',[1 1 1]);
set(0,'defaultuicontrolunits','normalized');
% Header information
program_version = uicontrol('style','text','position',[.00 .95 .25 .05],'string', version_name,'BackgroundColor',[1 1 1]);
program_title = uicontrol('style','text','position',[.25 .95 .50 .05],'string', 'Your Oligomer Pipeline Interface','BackgroundColor',[1 1 .5]);
status_title  = uicontrol('style','text','position',[.75 .95 .25 .05],'string', 'Not running','BackgroundColor',[.5 1 .5]);

% Here are the four panels
Configuration_panel = uipanel('parent',MAIN_FIGURE,'Title','Configuration','BackgroundColor','white','Position',[0.00 0.00 .25 .95]);
Preprocessing_panel = uipanel('parent',MAIN_FIGURE,'Title','Preprocessing','BackgroundColor','white','Position',[0.25 0.00 .25 .95]);
Analysis_panel      = uipanel('parent',MAIN_FIGURE,'Title','Analysis',     'BackgroundColor','white','Position',[0.50 0.00 .25 .95]);
Plotting_panel      = uipanel('parent',MAIN_FIGURE,'Title','Plotting',     'BackgroundColor','white','Position',[0.75 0.00 .25 .95]);
%% SECTION 2: CONFIGURATION PANEL
% Default path, change path
uicontrol('parent',Configuration_panel,'style','text','position',[0  .95 1 .05],'string','Configurations folderl');
uicontrol('parent',Configuration_panel,'style','text','position',[00  .80 1.0 .05],'string','Oligomer detection');
selection_configuration_ol = uicontrol('parent',Configuration_panel,'style','popupmenu','position', [.00  .75 1.0 .05],'string',{''},'callback',{@Display_configuration,'olig'});
uicontrol('parent',Configuration_panel,'style','text','position',[00  .70 1 .05],'string','Large object detection');
selection_configuration_lb = uicontrol('parent',Configuration_panel,'style','popupmenu','position', [.00  .65 1.0 .05],'string',{''},'callback',{@Display_configuration,'lb'});
uicontrol('parent',Configuration_panel,'style','text','position',[00  .60 1 .05],'string','Cell detection');
selection_configuration_cell = uicontrol('parent',Configuration_panel,'style','popupmenu','position', [.00  .55 1.0 .05],'string',{''},'callback',{@Display_configuration,'cell'});



selection_configuration_folder = uicontrol('parent',Configuration_panel,'style','togglebutton','position', [.00  .90 1.0 .05],'string',defaults_configurations_path,'Value',0,'callback',{@Directory_select,'Configurations_folder'});     
configuration_options = dir([defaults_configurations_path '\*json']);
selection_configuration_ol.String = {configuration_options.name};
selection_configuration_lb.String = {configuration_options.name};
selection_configuration_cell.String = {configuration_options.name};

% Channel
uicontrol('parent',Configuration_panel,'style','text','position',[0  .45 .75 .05],'string','Aggregate channel');
conf.channel_agg = uicontrol('parent',Configuration_panel,'style','text','position',[.75  .45 .25 .05],'string','');

% Channel
uicontrol('parent',Configuration_panel,'style','text','position',[0  .40 .75 .05],'string','Cell channel');
conf.channel_cell = uicontrol('parent',Configuration_panel,'style','text','position',[.75  .40 .25 .05],'string','');


uicontrol('parent',Configuration_panel,'style','text','position',[0  .3 1 .05],'string','Last configuration selected');
% Width
uicontrol('parent',Configuration_panel,'style','text','position',[0  .25 .5 .05],'string','width');
conf.width = uicontrol('parent',Configuration_panel,'style','text','position',[.5  .25 .5 .05],'string','');
% Height
uicontrol('parent',Configuration_panel,'style','text','position',[0  .20 .5 .05],'string','height');
conf.height = uicontrol('parent',Configuration_panel,'style','text','position',[.5  .20 .5 .05],'string','');
% Frames
uicontrol('parent',Configuration_panel,'style','text','position',[0  .15 .5 .05],'string','frames','fontsize',10);
conf.frames = uicontrol('parent',Configuration_panel,'style','text','position',[.5  .15 .5 .05],'string','');
% Slices
uicontrol('parent',Configuration_panel,'style','text','position',[0  .10 .5 .05],'string','z slices');
conf.slices = uicontrol('parent',Configuration_panel,'style','text','position',[.5  .10 .5 .05],'string','');
% Color
uicontrol('parent',Configuration_panel,'style','text','position',[0  .05 .5 .05],'string','colour');
conf.colour = uicontrol('parent',Configuration_panel,'style','text','position',[.5  .05 .5 .05],'string','');

% This does not work yet.
save_configuration_button = uicontrol('parent',Configuration_panel,'style','pushbutton','position', [.00 .00 1 .05],'string','save configuration','callback',{@SAVE_CONFIGURATION}); %#ok<NASGU> 

%% SECTION 3: PREPROCESSING
uicontrol('parent',Preprocessing_panel,'style','text','position', [.00  .95 1.0 .05],'string','Raw data location');     
selection_preprocessing_folder = uicontrol('parent',Preprocessing_panel,'style','togglebutton','position', [.00  .9 1.0 .05],'string',defaults_imagedata_path,'Value',0,'callback',{@Directory_select,'Preprocessing_folder'});     
uicontrol('parent',Preprocessing_panel,'style','text','position', [.00  .7 1.0 .2],'string','Example: \elephant_projects\2021_ASAP_pilot_study\Pilot - Week1 Round1\sample1\sample1_3');     


run_preprocessing_button = uicontrol('parent',Preprocessing_panel,'style','pushbutton','position', [.00 .05 1 .05],'string','time-average data','callback',{@PREPROCESS_DATA}); %#ok<NASGU> 
run_preprocessing_button = uicontrol('parent',Preprocessing_panel,'style','text','position', [.00 .00 1 .05],'string','*Uses Oligomer Configuration','callback',{@PREPROCESS_DATA}); %#ok<NASGU> 


% Add focus analysis option (or manual selection).

%% SECTION 4: ANALYSIS
uicontrol('parent',Analysis_panel,'style','text','position', [.00  .95 1.0 .05],'string','Metadata location');     
find_backslash = strfind(selection_preprocessing_folder.String,'\');
filepath_metadata = [selection_preprocessing_folder.String(1:find_backslash(end-1)),'compressed\metadata.csv'];
selection_metadata_file = uicontrol('parent',Analysis_panel,'style','togglebutton','position', [.00  .9 1.0 .05],'string',filepath_metadata,'Value',0,'callback',{@Directory_select,'Metadata_file'});     

% Type of analysis
uicontrol('parent',Analysis_panel,'style','text','position', [.00  .84 1.0 .05],'string','Analysis method');     
settings.Oligomer_analysis = uicontrol('parent',Analysis_panel,'style','checkbox','position',[0  .79 1 .05],'string','Oligomer','value',1);
settings.cell_analysis = uicontrol('parent',Analysis_panel,'style','checkbox','position',[0  .74 1 .05],'string','Cell analysis');

% Type of focus selection
uicontrol('parent',Analysis_panel,'style','text','position', [.00  .68 1.0 .05],'string','Z-plane selection');     
settings.analysis_group = uibuttongroup('Visible','on','Position',[0 .58 1 .1],'parent',Analysis_panel,'SelectionChangedFcn',@Slice_selection_method);
% Create three radio buttons in the button group.
settings.analysis1 = uicontrol(settings.analysis_group,'Style','radiobutton','String','Autofocus','Position',[.00  .5 1.0 .5],'value',1);%,'parent',Analysis_panel);
settings.analysis2  = uicontrol(settings.analysis_group,'Style','radiobutton','String','Manual z-range','Position',[.00  .00 1.0 .5],'value',0);%,'parent',Analysis_panel);

% First frame
    uicontrol('parent',Analysis_panel,'style','text','position',[0  .53 .5 .05],'units','normalized','string','First Frame','fontsize',10);
    settings.firstframe = uicontrol('parent',Analysis_panel,'style','text','position',[.5  .53 .5 .05],'units','normalized','string','1','fontsize',10,'callback',{@CHANGE_CONFIGURATION});
% Last Frame
    uicontrol('parent',Analysis_panel,'style','text','position',[0  .49 .5 .05],'units','normalized','string','Last Frame','fontsize',10);
    settings.lastframe = uicontrol('parent',Analysis_panel,'style','text','position',[.5  .49 .5 .05],'units','normalized','string','17','fontsize',10,'callback',{@CHANGE_CONFIGURATION});
   
% Type of analysis
uicontrol('parent',Analysis_panel,'style','text','position', [.00  .43 1.0 .05],'string','Save data');     
settings.save_oligomer_table = uicontrol('parent',Analysis_panel,'style','checkbox','position',[0  .39 1 .05],'string','Oligomer table','value',1);
settings.save_oligomer_mask = uicontrol('parent',Analysis_panel,'style','text','position',[0  .34 1 .05],'string','Oligomer mask','value',0);
settings.save_Large_aggregate_table = uicontrol('parent',Analysis_panel,'style','checkbox','position',[0  .29 1 .05],'string','Large-aggregate table','value',0);
settings.save_Large_aggregate_mask = uicontrol('parent',Analysis_panel,'style','text','position',[0  .24 1 .05],'string','Large-aggregate mask','value',0);
settings.save_cell_mask = uicontrol('parent',Analysis_panel,'style','text','position',[0  .19 1 .05],'string','Cell mask','value',0);


run_analysis_button = uicontrol('parent',Analysis_panel,'style','pushbutton','position', [.00 .00 1 .05],'string','analyse data','callback',{@ANALYSE_DATA}); %#ok<NASGU> 


%% SECTION 5: VISUALIZATION
uicontrol('parent',Plotting_panel,'style','text','position', [.00  .95 1.0 .05],'string','Aggregate data');     
uicontrol('parent',Plotting_panel,'style','text','position', [.00  .90 1.0 .05],'string','Select path');     
uicontrol('parent',Plotting_panel,'style','text','position', [.00  .85 1.0 .05],'string','choose name');     


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
            configuration_options = dir([filepath '*json']);
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
            selection_preprocessing_folder.Value = 1;
        end
    catch
    if filepath==0 || numel(filepath)==1
        status_title.String='Reselect path';

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
    conf.width.String = s.width;
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

function Slice_selection_method(~,~)
    if settings.analysis_group.Children(2).Value
        settings.firstframe.Style = 'text';
        settings.lastframe.Style = 'text';
    elseif settings.analysis_group.Children(1).Value
        settings.firstframe.Style = 'edit';
        settings.lastframe.Style = 'edit';
    end
end

function PREPROCESS_DATA(~,~)
    % This function will create a new directory with the same data; 
    % Then in the original directory, data is time-averaged
    status_title.String = 'Time-averaging data';
    status_title.BackgroundColor=[1 .5 .5];
    drawnow;

    % Magic is done here.
    all_tif_paths = dir([selection_preprocessing_folder.String, '**\*.tif']);
    status = zeros(1,numel(all_tif_paths));
    if isempty(all_tif_paths)
        status_title.String='Preprocessing failed';
        disp('no tif files found');
        return
    else
        f = waitbar(0,'Compressing data...');
        for file_number = 1:numel(all_tif_paths)
             waitbar(file_number/numel(all_tif_paths),f,'Compressing data...');

            % This will make the copy
            source = fullfile(all_tif_paths(file_number).folder,all_tif_paths(file_number).name);
            if contains(source,'compressed')
                status(file_number) = -1;
                continue;
            end
            backslash = strfind(selection_preprocessing_folder.String,'\');
            target_directory = strrep(all_tif_paths(file_number).folder,selection_preprocessing_folder.String,[selection_preprocessing_folder.String(1:backslash(end-1)),'compressed\']);
            mkdir(target_directory);
            destination = fullfile(target_directory,all_tif_paths(file_number).name);
            % This will flatten the image
            s1 = loadJSON([selection_configuration_folder.String, selection_configuration_ol.String{selection_configuration_ol.Value}]);
            img         = loadImage(source,s1);
            img         = uint16(squeeze(mean(img,4)));%xyzc
            img         = cat(3,img(:,:,:,1),img(:,:,:,2));
            Tifwrite(img,destination);
        end
        close(f)

    end
backslash = strfind(selection_preprocessing_folder.String,'\');
T = makeMetadata([selection_preprocessing_folder.String(1:backslash(end-1)),'compressed\']);
filename_metadata = [selection_preprocessing_folder.String(1:backslash(end-1)),'compressed\metadata.csv'];
writetable(T,filename_metadata);
selection_metadata_file.String = filename_metadata;
%     if any(status == 0) 
%         status_title.String='Preprocessing failed';
%     else
status_title.String='Not running';
status_title.BackgroundColor=[.5 1 .5];

%     end
end

function ANALYSE_DATA(~,~)
    status_title.String = 'Processing data';
    status_title.BackgroundColor=[1 .5 .5];
    drawnow;
    if settings.analysis_group.Children(2).Value % Autofocus
        disp('Autofocus is not yet functional, reselect with manual z range.');
        status_title.String='Change focus setting';
        status_title.BackgroundColor=[1 1 .5];
        return;
    elseif settings.analysis_group.Children(1).Value % Manual Z range;
        zi       = str2double(settings.firstframe.String); %initial slice
        zf       = str2double(settings.lastframe.String); %final slice
%         channel  = str2double(conf.channel_agg.String); %used colour channel
    end
%% Based on Main_quick
    try
    T = readtable(selection_metadata_file.String);
    catch
        disp('Select the correct metadata.csv file');
        status_title.String='metadata not found.';
        status_title.BackgroundColor=[1 1 .5];
        return;
    end
    names    = T.filenames;
%     names    = {files.name}';
    s1       = loadJSON('config_lb_biscut.json'); %lb
    s2       = loadJSON('config_oligomer_biscut.json'); %oligomer
    s        = loadJSON('config_microglia_biscut.json'); %cell
f = waitbar(0,'Compressing data...');
for i = 1:length(names)
    waitbar(i/numel(names),f,'Segmenting data.');
    slices = s1.slices;%
    img_original = Tifread(names{i});
    % Aggregate analysis
    if settings.Oligomer_analysis.Value
        channel = s1.channel;
        first_frame = slices*(channel-1)+zi;
        last_frame = first_frame+zf-zi;
        img_agg = img_original(:,:,first_frame:last_frame);
        [smallM,largeM,result_oligomer,~] = aggregateDetection(img_agg,s1,s2,zi,1); %aggregate, large and small
    end
    % Cell analysis
    if settings.cell_analysis.Value
        channel = s.channel;
        first_frame = slices*(channel-1)+zi;
        last_frame = first_frame+zf-zi+1;
        img_cell = img_original(:,:,first_frame:last_frame);
        cellM = process.cellDetection(img_cell,s); %cell
    end

    % If any of the saved data is on...
    full_target_path = strrep(names{i},'\compressed\','\analyzed\');
    backslash = strfind(full_target_path,'\');
    filename_only = full_target_path(backslash(end)+1:end);
    target_directory = full_target_path(1:backslash(end));
    newFolder = makeDir(target_directory);

    % If large aggregate save table is on
    if settings.save_Large_aggregate_table.Value
    boundaries = array2table(BW2boundary(largeM,zi),'VariableNames',{'row','col','z'});
    writetable(boundaries,fullfile(newFolder,strrep(filename_only,'.tif','_large_aggregates.csv')));
    end

    if settings.save_Large_aggregate_mask.Value
        largeM;
    end

    % If small aggregate save table is on
    if settings.save_oligomer_table.Value
    writetable(result_oligomer,fullfile(newFolder,strrep(filename_only,'.tif','_small_aggregates.csv')));
    end

    if settings.save_oligomer_mask.Value
        smallM;
    end
end
close(f);

% Determine directory from metadata...
% if settings.save_oligomer_mask.Value
%     Tifwrite(smallM,target_directory);
% end
% 
% if settings.save_large_aggregate_mask.Value
%     Tifwrite(largeM,target_directory);
% end

% filepath = {1};
% newFolder  = makeDir(fullfile(['.\pilot_result\',filepath{i}]));
% boundaries = array2table(BW2boundary(largeM,z(i,1)),'VariableNames',{'row','col','z'});
% writetable(r_z,fullfile(newFolder,'result_small_aggregates_561.csv'));
% writetable(boundaries,fullfile(newFolder,'result_large_aggregates_561.csv'));
status_title.String = 'Finished processing data';
status_title.BackgroundColor=[.5 1 .5];
end
end