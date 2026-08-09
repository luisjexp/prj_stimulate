classdef DataLog < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
% ----------------
    properties (Constant)
        wheelFile_idx               = 1;
        wheelFile_extension         = '.whl';
        wheelFile_VarDisplay        = ['%.03f ', '%d\n']; 

        sensorFile_idx              = 2;        
        sensorFile_extension        = '.sns';
        sensorFile_VarDisplay       = '%.03f\n'; 

        systemFile_idx              = 3;                
        systemFile_extension        = '.evt';         
        systemFile_VarDisplay       = {'%.03f ', '%s ',     '%s ',    '%.01f\n'};
        
        trialFile_idx              = 4;                
        trialFile_extension        = '.trl';         
        trialFile_VarDisplay       = {};
    end    
 
    methods (Static)
        function F = initiateFileInfoList
            F(DataLog.wheelFile_idx).ext        =  DataLog.wheelFile_extension;            
            F(DataLog.wheelFile_idx).id         =  [];            
            F(DataLog.wheelFile_idx).name       =  [];
            F(DataLog.wheelFile_idx).nameWithPath = [];
            
            F(DataLog.sensorFile_idx).ext       =  DataLog.sensorFile_extension;
            F(DataLog.sensorFile_idx).id        =  [];
            F(DataLog.sensorFile_idx).name      =  [];
            F(DataLog.sensorFile_idx).nameWithPath =  [];
            
            F(DataLog.systemFile_idx).ext       =  DataLog.systemFile_extension;
            F(DataLog.systemFile_idx).id        =  []; 
            F(DataLog.systemFile_idx).name      =  [];          
            F(DataLog.systemFile_idx).nameWithPath =  []; 
            
            F(DataLog.trialFile_idx).ext       =  DataLog.trialFile_extension;
            F(DataLog.trialFile_idx).id        =  []; 
            F(DataLog.trialFile_idx).name      =  [];          
            F(DataLog.trialFile_idx).nameWithPath =  [];     
        end
        
    end
    
  
% ----------------
    properties 
        FileSet
        fileSetOpen = false;
        numericId
    end
    
    methods
        function openFileDataSet(obj, mouseId)
            [obj.FileSet, obj.numericId] = createNewDataFile(mouseId);
            obj.fileSetOpen = true;
        end
    
        function obj = write2DataFile(obj, data, fileExt)
            if obj.fileSetOpen
                switch fileExt
                    case DataLog.wheelFile_extension
                        fid= obj.FileSet(DataLog.wheelFile_idx).id; 
                        fprintf(fid, DataLog.wheelFile_VarDisplay, data);            
                    case DataLog.sensorFile_extension
                        fid= obj.FileSet(DataLog.sensorFile_idx).id; 
                        fprintf(fid, DataLog.sensorFile_VarDisplay, data);               
                    case DataLog.systemFile_extension 
                        fid= obj.FileSet(DataLog.systemFile_idx).id;                         
                        cellfun(@(disp, cellData)  fprintf(fid,disp,cellData),   DataLog.systemFile_VarDisplay, data) ; 
                    case DataLog.systemFile_extension  
                        fid= obj.FileSet(DataLog.stimFile_idx).id;                         
                        cellfun(@(disp, cellData)  fprintf(fid,disp,cellData),   DataLog.stimFile_VarDisplay, data) ; 
                    case DataLog.trialFile_extension
                        fid= obj.FileSet(DataLog.trialFile_idx).id;                         
                        fprintf(fid, '%s', data);               
                        
                    otherwise 
                        error('Unkown File with that extention')
                end
            end
            

            
        end

        function obj = closeDataFileSet(obj)
            if obj.fileSetOpen
                for i = 1:numel(obj.FileSet)
                    fclose(obj.FileSet(i).id);
                end
                    obj.fileSetOpen = false; 
            end
        end
        
        
    end
   
  methods (Static)
        
        function data = viewDataFile
            if ispc
                d = dir([cd '\beh_data']); 
            elseif ismac
                 d = dir([cd '/beh_data']);                                
            end
            mouseFolders = d([d.isdir]);
            mouseFolders = mouseFolders(3:end);
            nMiceDataSets = numel(mouseFolders);
            data(nMiceDataSets) = struct('mouse', [], 'path', [], 'fileList', []);
            
            for i = 1:nMiceDataSets
                if ispc
                    fname           = [mouseFolders(i).folder, '\', mouseFolders(i).name];
                elseif ismac
                    fname           = [mouseFolders(i).folder, '/', mouseFolders(i).name];
                end
                dataFileList    = getBehDataFileList(fname);
                data(i).path    = mouseFolders(i).folder;
                data(i).mouse   = mouseFolders(i).name;
                data(i).fileList = dataFileList;
            end
            
        end

        
        function fname = getLastDataFile(mouse)
            fname = DataLog.viewDataFile;
            idx = contains({fname.mouse},mouse);
            if any(idx)
                fname = fname(idx).fileList{end};
            else
                fname = 'no files avlble';
            end
        end       
        
    end
    
    
end

%%

function [F, numericId] = createNewDataFile(mouseId)
    if ismac
        dataPath    = [cd '/beh_data/',  mouseId]; 
    elseif ispc
        dataPath    = [cd '\beh_data\',  mouseId]; 
    end
    
    % Step 1: If mouse data folder does not exist then create one    
    if ~exist(dataPath, 'dir')
        mkdir(dataPath);
        fprintf('\nNEW FOLDER CREATED for mouse %s', mouseId)
    end    
    
    % get the name of folder in data path (should be named after mouse)    
    % get list of all file names in data path folder 
    % find files with appropriate name structure and extension
    % - folderName_###.mat are data files) - where ### is the phase Id value
    % then get the file id values from thes file names.
    % Will return as empty if there are no data files in folder
    
    [dataFileList, folderName] = getBehDataFileList(dataPath);
    fldrNameLength = numel(folderName);
    phaseValuesUsed     = zeros(1,numel(dataFileList));
    for i = 1:numel(dataFileList)
        fname_i = dataFileList{i};
        phaseValue_str = fname_i(fldrNameLength+2:end-4);
        phaseValuesUsed(i) = str2double(phaseValue_str);
    end
        
    % if there are no data files, then assume this is the first phase (e.g. phase 000)
    % If there is a data file, then add one to the largest id value found. 
    if  isempty(phaseValuesUsed)
         phaseValue = 0;
    else
        phaseValue = max(phaseValuesUsed)+1; 
    end
    
    %  Name the file based on the assigned phase 
    numericId     = sprintf('%.04d', phaseValue);  
        
    
    F = DataLog.initiateFileInfoList;
    numFiles = numel(F);
    fprintf('\n%d NEW DATA FILE SET CREATED for mouse %s\n',numFiles,  mouseId)
    
    for i = 1:numFiles
        F(i).name = sprintf(['%s_%s',F(i).ext], folderName, numericId);
        if ispc
            F(i).nameWithPath = [dataPath '\'  F(i).name]; 
        elseif ismac
            F(i).nameWithPath = [dataPath '/'  F(i).name];         
        end
        F(i).id = fopen(F(i).nameWithPath, 'w');        
        fprintf('\t- %s\n', F(i).name);
    end
end

function [dataFileList, dirFolderName] = getBehDataFileList(directory)
% returns a list file names in the directory that match the naming
% convention used to store behavioral data file
    
    if ispc
    i               = strfind(directory, '\');
    elseif ismac
    i               = strfind(directory, '/');
    end
    
    dirFolderName   =  directory(i(end)+1:end);                 % data files are prefixed with the name of directory folder
    
    
    dataFileNameStructure = [dirFolderName, '_\d\d\d\d'];   %  end with a 4 digit id, and are txt files (for now)
    
    filelist = dir(directory); 
    filelist = {(filelist.name)}; % returns list of ALL files in directory
    dataFileList = filelist( cellfun(@(s) ~isempty(s), regexp(filelist, dataFileNameStructure) ) );   % returns only file names with appropriate naming structure 
    
    if isempty(dataFileList)
       fprintf('\nNo behavioral data files found in this directory\n')
    end
    
end
