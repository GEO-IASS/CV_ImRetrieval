function [feat] = getfeat5(im, D)
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
    %descs = bsxfun(@rdivide, bsxfun(@minus, descs, mean(descs, 1)), sqrt(var(descs, [], 1)+10));
    
    xx = sum(descs.^2, 1);
    yy = sum(D.^2, 1);
    xy = descs' * D;
    
    dis = sqrt( bsxfun(@plus, yy, bsxfun(@minus, xx', 2*xy)) );
    
    feat = max(bsxfun(@minus, mean(dis, 2), dis), 0);
    feat = sum(feat, 1);
end
