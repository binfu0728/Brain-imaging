

function [] = GUI2BIN_v03()
version_name = 'GUI2BIN_v03';

%% SET DEFAULT DATAPATHS
% This will be the default image-data folder, have a \ at the end of the path
defaults_imagedata_path = 'D:\LEW_ASAP_Data_TEMP\';
% This is where your GITHUB Brain-imaging folder is selected
defaults_functions_path = 'D:\Github\Brain-imaging\Brain-imaging\code\';
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
uicontrol('parent',Configuration_panel,'style','text','position',[00  .9 1.0 .05],'string','Oligomer detection');
selection_configuration_ol = uicontrol('parent',Configuration_panel,'style','popupmenu','position', [.00  .85 1.0 .05],'string',{''},'callback',@Display_configuration);
uicontrol('parent',Configuration_panel,'style','text','position',[00  .8 1 .05],'string','Large object detection');
selection_configuration_lb = uicontrol('parent',Configuration_panel,'style','popupmenu','position', [.00  .75 1.0 .05],'string',{''},'callback',@Display_configuration);
uicontrol('parent',Configuration_panel,'style','text','position',[00  .7 1 .05],'string','Cell detection');
selection_configuration_cell = uicontrol('parent',Configuration_panel,'style','popupmenu','position', [.00  .65 1.0 .05],'string',{''},'callback',@Display_configuration);



selection_configuration_folder = uicontrol('parent',Configuration_panel,'style','togglebutton','position', [.00  .95 1.0 .05],'string',defaults_configurations_path,'Value',0,'callback',{@Directory_select,'Configurations_folder'});     
configuration_options = dir([defaults_configurations_path '\*json']);
selection_configuration_ol.String = {configuration_options.name};
selection_configuration_lb.String = {configuration_options.name};
selection_configuration_cell.String = {configuration_options.name};

% Channel
uicontrol('parent',Configuration_panel,'style','text','position',[0  .7 .5 .05],'string','Agg channel');
conf.channel_agg = uicontrol('parent',Configuration_panel,'style','text','position',[.5  .7 .5 .05],'string','');

% Channel
uicontrol('parent',Configuration_panel,'style','text','position',[0  .7 .5 .05],'string','cell channel');
conf.channel_cell = uicontrol('parent',Configuration_panel,'style','text','position',[.5  .7 .5 .05],'string','');


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
selection_preprocessing_folder = uicontrol('parent',Preprocessing_panel,'style','togglebutton','position', [.00  .95 1.0 .05],'string',defaults_imagedata_path,'Value',0,'callback',{@Directory_select,'Preprocessing_folder'});     

run_preprocessing_button = uicontrol('parent',Preprocessing_panel,'style','pushbutton','position', [.00 .00 1 .05],'string','time-average data','callback',{@PREPROCESS_DATA}); %#ok<NASGU> 


% Add focus analysis option (or manual selection).

%% SECTION 4: ANALYSIS
selection_metadata_file = uicontrol('parent',Analysis_panel,'style','togglebutton','position', [.00  .95 1.0 .05],'string',defaults_imagedata_path,'Value',0,'callback',{@Directory_select,'Preprocessing_folder'});     


% Color
uicontrol('parent',Analysis_panel,'style','checkbox','position',[0  .9 1 .05],'string','Oligomer');
uicontrol('parent',Analysis_panel,'style','checkbox','position',[0  .85 1 .05],'string','Cell analysis');



run_analysis_button = uicontrol('parent',Analysis_panel,'style','pushbutton','position', [.00 .00 1 .05],'string','analyse data','callback',{@ANALYSE_DATA}); %#ok<NASGU> 


%% SECTION 5: VISUALIZATION

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

function Display_configuration(self,~)
    filename = self.String{self.Value};
    filepath = selection_configuration_folder.String;
    s = loadJSON([filepath,filename]);
    conf.channel.String = s.channel;
    conf.width.String = s.width;
    conf.height.String = s.height;
    conf.frames.String = s.frames;
    conf.slices.String = s.slices;
    conf.colour.String = s.colour;
end

function SAVE_CONFIGURATION(~,~)
    disp('Option not available yet; select from available configurations');
end

function PREPROCESS_DATA(~,~)
    % This function will create a new directory with the same data; 
    % Then in the original directory, data is time-averaged
    status_title.String = 'Time-averaging data';
    status_title.BackgroundColor=[1 .5 .5];

    % Magic is done here.
    all_tif_paths = dir([selection_preprocessing_folder.String, '**\*.tif']);
    status = zeros(1,numel(all_tif_paths));
    if isempty(all_tif_paths)
        status_title.String='Preprocessing failed';
        disp('no tif files found');
        return
    else
        for file_number = 1:numel(all_tif_paths)
            % This will make the copy
            source = fullfile(all_tif_paths(file_number).folder,all_tif_paths(file_number).name);
            if contains(source,'compressed')
                status(file_number) = -1;
                continue;
            end
            target_directory = strrep(all_tif_paths(file_number).folder,selection_preprocessing_folder.String,[selection_preprocessing_folder.String,'compressed\']);
            mkdir(target_directory);
            destination = fullfile(target_directory,all_tif_paths(file_number).name);
%             status(file_number) = copyfile(source,destination);
% Check Image
            % This will flatten the image
            s1 = loadJSON([selection_configuration_folder.String, selection_configuration_lb.String{selection_configuration_lb.Value}]);
            img         = loadImage(source,s1);
            img         = uint16(squeeze(mean(img,4)));%xyzc
%             zi = 1;
%             zf = size(img,3);
%             channel = s1.channel;
%             img        = img(:,:,zi:zf,channel);
            img         = cat(3,img(:,:,:,1),img(:,:,:,2));
            Tifwrite(img,destination);
        end
    end
    if any(status == 0) 
        status_title.String='Preprocessing failed';
    else
        status_title.String='Not running';
        status_title.BackgroundColor=[.5 1 .5];
    end

end

function ANALYSE_DATA(~,~)
%% Based on Main_quick
zi       = 4; %initial slice
zf       = 14; %final slice
channel  = 2; %used colour channel
%%
files    = dir([pwd,'\*.tif']);
names    = {files.name}';
s1       = load.loadJSON('config_lb_biscut.json'); %lb
s2       = load.loadJSON('config_oligomer_biscut.json'); %oligomer
s        = load.loadJSON('config_microglia_biscut.json'); %cell

for i = 1%:length(names)
    slices = s1.slices;%
    img_original = Tifread(names{i});
    % Aggregate analysis
    channel = s1.channel;
    first_frame = slices*(channel-1)+zi;
    last_frame = first_frame+zf-zi+1;
    img_agg = img_original(:,:,first_frame:last_frame);
    [smallM,largeM] = process.aggregateDetection(img_agg,s1,s2,zi,0); %aggregate, large and small
    % Cell analysis
    channel = s.channel;
    first_frame = slices*(channel-1)+zi;
    last_frame = first_frame+zf-zi+1;
    img_agg = img_original(:,:,first_frame:last_frame);
    cellM           = process.cellDetection(img_cell,s); %cell
end
% Determine directory from metadata...
newFolder  = load.makeDir(fullfile(['.\pilot_result\',filepath{i}]));
boundaries = array2table(load.BW2boundary(largeM,z(i,1)),'VariableNames',{'row','col','z'});
writetable(r_z,fullfile(newFolder,'result_small_aggregates_561.csv'));
writetable(boundaries,fullfile(newFolder,'result_large_aggregates_561.csv'));

end
end