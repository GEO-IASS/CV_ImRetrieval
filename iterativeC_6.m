function [cs, divideP, indInLevel] = iterativeC_6(A, numEachLevel)
    if nargin <2 
        numEachLevel = 1;
    end
    
    maxC = 100;
    
    cs = cell(1, maxC);
    divideP = cell(1, maxC);
    indInLevel = cell(1, maxC);
    
    divideDecrease = 0.00003;
    
    % A_t = A{1};
    
    ind = 1;
    
    while ind < maxC %&& objs > minObjs
        dividePoint = 0.99999 + divideDecrease;
        
        %%%%%%%%%%%%%%%%%
        % stop condition
        if size(getlablist(A{1}), 1) <2
            size(A{1})
            break;
        end
        
        for i = 1:length(A)
            A{i} = remclass(A{i},2);
        end
        
        tempC = cell(1, length(A));
        con = zeros(size(A{1}, 1), size(getlablist(A{1}), 1), length(A));
        
        for i = 1:length(A)
            tempC{i} = qdc(A{i});
            con(:,:,i) = +classc(A{i}*tempC{i});
        end
        
        con = max(con, [], 2);
        threshNum = min(2, size(A{1}, 1)/20);
        %threshNum = 2;
        
        numBig = 0;
        cBig = zeros(1, length(A));
        
        tp = 0;
        while numBig < numEachLevel
            dividePoint = dividePoint - divideDecrease;
            numBig = 0;
            for i = 1:length(A)
                cBig(i) = length(find(con(:,:,i) > dividePoint));
                if cBig(i) > threshNum
                    numBig = numBig + 1;
                    tp = max(tp, dividePoint);
                end
            end
        end
        
        dividePoint = tp;
        
        %cBig(cBig <= threshNum) = size(A{i}, 1) + 10;
        
        %[~, t] = sort(cBig, 'ascend');
        [~, t] = sort(cBig, 'descend');
        
        tempC = tempC(t);
        
        cs{ind} = tempC(1:numEachLevel);
        indInLevel{ind} = t(1:numEachLevel);
        divideP{ind} = dividePoint;
        
        for i = 1:length(A)
            A{i} = A{i}(con(:,:,t(numEachLevel)) < dividePoint, :);
        end
        
        length(find(con(:,:,t(numEachLevel)) < dividePoint))
%         
%         con = +classc(A_t*cs{ind});
%         con = max(con, [], 2);
%         threshNum = min(5000, size(A_t, 1)/10);
%         while length(find(con > dividePoint)) < threshNum
%             dividePoint = dividePoint - 0.01;
%         end
%         
%         divideP{ind} = dividePoint;
%         
%         if dividePoint < 0.6
%             %size(A_t, 1)
%             %break;
%         end
%         
%         objs = length(find(con < dividePoint));
%         
%         A_t = A_t(con < dividePoint, :);
        
        ind = ind + 1;
    end
    
    cs(cellfun(@isempty, cs)) = [];
    divideP(cellfun(@isempty, divideP)) = [];
    indInLevel(cellfun(@isempty, indInLevel)) = [];
end