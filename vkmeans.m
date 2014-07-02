function [clusters, assign] = vkmeans(X, K, Iteration)
%KMEANS Memory-efficient implementation of k-means clustering
%
%   [clusters, assign] = kmeans(X, K)
%
% Memory-efficient implementation of k-means clustering.

    % Initialize some variables
    tol = 1e-5;
    
    if nargin < 3
        max_iter = 100;
    else
        max_iter = Iteration;
    end
    %batch_size = 2 ^ 13;
    N = size(X, 2);
    assign = zeros(1, N);
    
    % Initialize clusters from data points
    perm = randperm(N);
    clusters = X(:,perm(1:K));
    
    clear perm
    % Perform precomputation
    %X2 = sum(X .^ 2, 1);
    
    % Perform k-means iterations
    iter = 0; change = Inf;
    while iter < max_iter %&& (change / N > tol || isnan(change))
        old_clusters = clusters;
        
        if size(X, 2) > 500000
            Inds = zeros(1, size(X, 2));
            %tic
            for i = 1:size(X,2)
                temp = clusters'*X(:,i);
                [~, temp] = max(temp);
                Inds(i) = temp;
            end
            %toc
        else
            KV = clusters'*X;
            [~,Inds] = max(KV);
        end
        
        %temp_c = clusters(:,Inds);
        
        td = clusters(:,Inds);
        td = sum(td.*X);
        
        %S = sparse(K, N);
        
%         ik = Inds(1:1:N);
%         jk = 1:1:N;
%         sk = td(1:1:N);
        
        S = sparse(Inds(1:1:N), 1:1:N, td(1:1:N));
%         for i = 1:N
%             S(Inds(i), i) = td(i);
%         end
        
        % S = sparse(S);
        
        SS = S*S';
        
        for i = 1:K
            if SS(i,i) == 0
                if i==1
                    SS(i,i) = SS(i+1,i+1);
                elseif i==K
                    SS(i,i) = SS(i-1,i-1);
                else
                    SS(i,i) = (SS(i+1,i+1) + SS(i-1,i-1))/2;
                end
            end
        end
        
        clusters = X*S'/(SS);
        
        avg = mean(clusters, 1);
        sd = std(clusters);
        
        sd(sd == 0) = sqrt(10);
        
        clusters = clusters - repmat(avg, size(clusters, 1), 1);
        clusters = clusters./repmat(sd, size(clusters, 1), 1);
        
        % Print out progress
        iter = iter + 1;
        %change = nanmean(nanmean(clusters - old_clusters));
        change = mean2(abs(clusters) - abs(old_clusters));
        disp(['   * iteration ' num2str(iter) ': ' num2str(change .* 100) '% of the assignments changed']);
    end
    
    % Remove empty clusters
    [~, c] = find(isnan(clusters));
    clusters(:,unique(c)) = [];    
    