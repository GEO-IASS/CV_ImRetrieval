function [labs, cons] = testIterativeC_5(A, cs, divideP, indInLevel)
    numEachLevel = length(cs{1});
    
    %con = zeros(size(A, 1), size(getlablist(A), 1));
    
    cons = cell(size(cs));
    indList = cell(size(cs));
    start = length(cs)-1;
    labs = zeros(size(A{1}, 1), length(cs));
    
    for i = 1:length(cs)
%         if isempty(A_t)
%             i
%         end
        cons{i} = +classc(A{indInLevel{i}(1)}*cs{i}{1});
        
        for j = 2:numEachLevel
            cons{i} = cons{i} + (+classc(A{indInLevel{i}(j)}*cs{i}{j}));
        end
        
        temp = max(cons{i}, [], 2);
        %temp(temp < divideP{i}) = 0;
        indList{i} = temp;
        
        for j = 1:length(A)
            A{j} = A{j}(temp < divideP{i}, :);
        end
        
        if isempty(A{1})
            start = i - 1;
            break;
        end
    end
    
    [~, labs(:, 1)] = max(cons{1}, [], 2);
    
    for i = 2:start
        tempC = cons;
        for j = i:-1:2
            %i
            temp = indList{j-1};
            try
            tempC{j-1}(temp < divideP{j-1}, :) = tempC{j};
            catch
            end
        end
        
        [~, labs(:, i)] = max(tempC{1}, [], 2);
    end

end