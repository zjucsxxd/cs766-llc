function [ feat ] = getfeat_single_image(imagepath, outputfilename, outputpath, savermap)
    mfilepath = fileparts(which('getfeat_single_image'));
	addpath(genpath(fullfile(mfilepath, 'code')));
	if ~exist('imagepath', 'var'), imagepath = 'ImageSet/1.jpg'; end
	if ~exist('outputfilename', 'var'), outputfilename = 'tmp'; end
	if ~exist('outputpath', 'var'), outputpath = outputfilename;
	else
		try
			if ~exist(outputpath), mkdir(outputpath); end
		catch
			fprintf('cannot make directory named %s\n', outputpath);
			exit(0);
		end
		outputpath = [outputpath '/' outputfilename];
	end
    if ~exist('savermap', 'var'), savermap = 0;
    else savermap = 1;
    end
    
    if exist([outputpath '-feat.mat'], 'file')
        load([outputpath '-feat.mat'], 'feat');
        return;
    end
    
	modelpath = 'Model';

	detectorlist = detectorset(); L = length(detectorlist);
	nlevel = 3; dim = 44604; interval=10; nmap = 12; Level=(interval+1):5:(interval+30);

	im = imread(imagepath); im = resize_img(im, 400);
	[feat_py, scales] = featpyramid(im, 8, 10);

	for l=1:L
		load(fullfile(mfilepath, modelpath, [num2str(detectorlist{l}), '_hard.mat']));
		responsemap = detect_with_responsemap(Level, feat_py, scales, im, model, model.thresh);
		currfeat = cell(1,nmap);
		for mapId = 1:nmap, currfeat{mapId} = MaxGetSpatialPyramid(responsemap{mapId}, nlevel); end
		featList{l} = vertcat(currfeat{:});
	end
	feat = vertcat(featList{:});

    save([outputpath '-feat.mat'], 'feat');

	if savermap==1, save([outputpath '-rmap.mat'], 'responsemap'); end
    rmpath(genpath(fullfile(mfilepath, 'code')));
end
