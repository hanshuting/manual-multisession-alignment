clear all;

%%
base_dir = 'W:\Transfer\Shuting\Xin_multi day recording';
file_names = {'XS089_20230811', 'XS089_20230812'};
nset = length(file_names);

save_path = fullfile(base_dir, 'results');
if ~exist(save_path)
    mkdir(save_path);
end

%% load template and spatial components
template = cell(1,nset);
ROI_mask = cell(1,nset);
for dataid = 1:nset
    
    data_file = fullfile(base_dir, file_names{dataid}, 'Fall.mat');
    data = load(data_file);
    dims = size(data.ops.meanImg);

    % save template - avg projection
%     im = data.ops.meanImg;

    % save template - max projection
    im = zeros(dims);
    im(data.ops.yrange(1)+1:data.ops.yrange(2), data.ops.xrange(1)+1:data.ops.xrange(2)) = ...
    data.ops.max_proj;
    
    template{dataid} = im;
    dims = size(im);
    
    % get spatial components
    for i = 1:length(data.stat)
        An = false(dims);
        idx = sub2ind(dims, data.stat{i}.ypix+1, data.stat{i}.xpix+1);
        An(idx) = 1;
        ROI_mask{dataid}.cent(i,:) = double(data.stat{i}.med([2,1])) + 1;
        ROI_mask{dataid}.cont{i} = cell2mat(bwboundaries(An==1));
    end
    
    ROI_mask{dataid}.cent = ROI_mask{dataid}.cent(data.iscell(:,1)==1,:);
    ROI_mask{dataid}.cont = ROI_mask{dataid}.cont(data.iscell(:,1)==1);
    
end

%% plot template
figure; set(gcf,'color','w');
for dataid = 1:nset
    subplot(1,nset,dataid);
    if isempty(template{dataid}); continue; end
    imagesc(template{dataid}); colormap(gray); hold on;
    title(['day ' num2str(dataid)], 'FontWeight', 'Normal');
    axis off;
end
linkaxes;

%% save
save(fullfile(save_path, 'template.mat'), 'template', '-v7.3');
save(fullfile(save_path, 'spatial.mat'), 'ROI_mask', '-v7.3');

    
