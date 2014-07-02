% t1
% need to be improved!!!!!!

data = cell(1,5);

data{1} = load('data_batch_1');
data{2} = load('data_batch_2');
data{3} = load('data_batch_3');
data{4} = load('data_batch_4');
data{5} = load('data_batch_5');

labs = [data{1}.labels; data{2}.labels; data{3}.labels; data{4}.labels; data{5}.labels];
labs = labs + 1;
labs = double(labs);

dim = [32 32];
level =12;

ims = zeros(50000, prod(dim));

% read images
ind = 1;
for i = 1:5
    for j = 1:size(data{i}.data, 1)
        temp = data{i}.data(j, :);
        temp = reshape(temp, [dim(1) dim(2) 3]);
        temp = imadjust(temp, stretchlim(temp), []);
        temp = rgb2gray(temp);
        ims(ind, :) = reshape(temp, 1, numel(temp));
        ind = ind + 1;
    end
end

clear ind temp i j

% extract all sift descriptors
descs = zeros(30*size(ims, 1), 128);
descs_addi = zeros(30*size(ims, 1), 2);
descs_labs = zeros(30*size(ims, 1), 1);

ind = 1;
for i = 1:size(ims, 1)
    if mod(i, 1000) == 0
        disp(['   Extracting SIFT descriptors of ', num2str(i), ' images...']);
    end
    level = 12;
    temp = ims(i, :);
    temp = reshape(temp, dim);
    [~, temp_d] = vl_sift(single(temp), 'Levels', level);
    while isempty(temp_d)
        level = level + 1;
        [~, temp_d] = vl_sift(single(temp), 'Levels', level);
    end
    descs(ind : ind + size(temp_d', 1) - 1, :) = temp_d';
    descs_addi(ind : ind + size(temp_d', 1) - 1, :) = repmat([level, size(temp_d', 1)], size(temp_d', 1), 1);
    descs_labs(ind : ind + size(temp_d', 1) - 1, :) = ones(size(temp_d', 1), 1)*labs(i);
    ind = ind + size(temp_d', 1);
end

descs(all(descs == 0, 2),:) = [];
descs_addi(all(descs_addi == 0, 2),:) = [];
descs_labs(all(descs_labs == 0, 2),:) = [];

%%%%%%% Do we need this normalization step????
% I guess no.
% descs = bsxfun(@rdivide, bsxfun(@minus, descs, mean(descs,2)), sqrt(var(descs,[],2)+10));

[codebook, ~] = vkmeans(descs', 500, 10);

% get train data
trainD = zeros(size(ims, 1), size(codebook, 2));
for i = 1:size(ims, 1)
    if mod(i, 1000) == 0
        disp(['   Extracting features of ', num2str(i), ' images...']);
    end
    trainD(i, :) = getfeat4(reshape(ims(i, :), dim), codebook);
end

trainD_mean = mean(trainD, 1);
trainD_sd = sqrt(var(trainD, 1) + 0.01);
trainDs = bsxfun(@rdivide, bsxfun(@minus, trainD, trainD_mean), trainD_sd);

% Use LIBLINEAR
trainDs_sparse = sparse(trainDs);
model = train(double(labs), trainDs_sparse, '-s 2 -B 1 -c 100');
[predicted_label, accuracy, prob_estimates] = predict(double(labs), trainDs_sparse, model);

% Use minFunc
trainDs_B = [trainDs, ones(size(trainDs,1),1)];
C = 100;
theta = train_svm(trainDs_B, double(labs), C);
[val,labels] = max(trainDs_B*theta, [], 2);
fprintf('Train accuracy %f%%\n', 100 * (1 - sum(labels ~= double(labs)) / length(double(labs))));

% get test data
test_data = load('test_batch');
