function [feat] = getfeat4(im, D)
    l = 12;
    
    [~, descs] = vl_sift(single(im), 'Levels', l);
    
    while isempty(descs)
        warning('No SIFT descriptor detected! Trying more level...');
        l = l + 1;
        [~, descs] = vl_sift(single(im), 'Levels', l);
    end
    %size(D')
    %size(descs)
    
    descs = double(descs);
    descs = bsxfun(@rdivide, bsxfun(@minus, descs, mean(descs, 1)), sqrt(var(descs, [], 1)+10));
    
    feat = abs(D'*double(descs));
    m = mean(feat, 1);
    
    %feat = feat - repmat(m, size(feat, 1), 1);
    
    feat = bsxfun(@minus, abs(feat), m);
    
    feat(feat < 0) = 0;
    
    feat = mean(feat, 2);
    
    feat = feat';
end
