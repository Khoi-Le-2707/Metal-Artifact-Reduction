%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%    Parameter    %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Generation of System Geometry

%% Original Prameters
    geo.DSD = 1458.24;                            % Distance Source Detector      (mm)
    geo.DSO = 931.08;                             % Distance Source Origin        (mm)
    % Detector parameters
    geo.nDetector=[900; 10];                
    geo.dDetector=[400/900; 400/900];                 % size of each pixel            (mm)
    geo.sDetector=geo.nDetector.*geo.dDetector;   % total size of the detector    (mm)
    % Image parameters
    geo.nVoxel=[512;512;10];                      % number of voxels              (vx)
    geo.dVoxel=[400/512; 400/512; 400/512];          % size of each voxel            (mm)
    geo.sVoxel=geo.nVoxel.*geo.dVoxel;
    
    % Offsets
    geo.offOrigin =[0;0;0];                       % Offset of image from origin   (mm)
    geo.offDetector=[0;0];                        % Offset of Detector            (mm)
    % Auxiliary
    geo.accuracy=0.5;                             % Accuracy of FWD proj          (vx/sample)

    view = 1000;
    Theta = 360; 
    angle_space = Theta/view;
    angles= 0:angle_space*pi/180:(Theta-angle_space)*pi/180;
    
%% FOV based MAR Prameters
    geo_fov.DSD = 1458.24;                           % Distance Source Detector      (mm)
    geo_fov.DSO = 931.08;                            % Distance Source Origin        (mm)
    % Detector parameters
    geo_fov.nDetector=[900*5; 10];                
    geo_fov.dDetector=[geo.dDetector(1)/5; geo.dDetector(1)];              % size of each pixel            (mm)
    geo_fov.sDetector=geo_fov.nDetector.*geo_fov.dDetector;% total size of the detector    (mm)
    % Image parameters
    geo_fov.nVoxel=[512;512;10];                     % number of voxels              (vx)
    geo_fov.dVoxel=[400/512; 400/512; 400/512];           % size of each voxel            (mm)
    geo_fov.sVoxel=geo_fov.nVoxel.*geo_fov.dVoxel;
    
    % Offsets
    geo_fov.offOrigin =geo.offOrigin;                      % Offset of image from origin   (mm)
    geo_fov.offDetector=geo.offDetector;                       % Offset of Detector            (mm)
    % Auxiliary
    geo_fov.accuracy=0.5;                            % Accuracy of FWD proj          (vx/sample)
    
%% Truncation correction Parameters
    geo_ex.DSD = 1458.24;                            % Distance Source Detector      (mm)
    geo_ex.DSO = 931.08;                             % Distance Source Origin        (mm)
    % Detector parameters
    geo_ex.nDetector=[900+200; 10];                
    geo_ex.dDetector=[geo.dDetector(1); geo.dDetector(1)];                 % size of each pixel            (mm)
    geo_ex.sDetector=geo_ex.nDetector.*geo_ex.dDetector;% total size of the detector    (mm)
    % Image parameters
    geo_ex.nVoxel=[512;512;10];                      % number of voxels              (vx)
    geo_ex.dVoxel=[400/512; 400/512; 400/512];            % size of each voxel            (mm)
    geo_ex.sVoxel=geo_ex.nVoxel.*geo_ex.dVoxel;
    
    % Offsets
    geo_ex.offOrigin = geo.offOrigin;                       % Offset of image from origin   (mm)
    geo_ex.offDetector=geo.offDetector;                        % Offset of Detector            (mm)
    % Auxiliary
    geo_ex.accuracy=0.5;                             % Accuracy of FWD proj          (vx/sample)

    
    
