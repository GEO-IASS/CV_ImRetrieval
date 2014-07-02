function [feat] = getfeat4(im, D)
    [~, descs] = vl_sift(single(im), 'Levels', 12);
    
    l = 12;
    while isempty(descs)
        warning('No SIFT descriptor detected! Trying more level...');
        l = l + 1;
        [~, descs] = vl_sift(single(im), 'Levels', l);
    end
    %size(D')
    %size(descs)
    
    feat = abs(D'*double(descs));
    m = mean(feat, 1);
    
    %feat = feat - repmat(m, size(feat, 1), 1);
    
    feat = bsxfun(@minus, abs(feat), m);
    
    feat(feat < 0) = 0;
    
    feat = mean(feat, 2);
    
    feat = feat';
end
