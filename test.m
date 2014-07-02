

re1 = zeros(1, size(labs1, 2));
for i = 1:size(labs1, 2)
    re1(i) = length(find(labs1(:,i) ~= getlab(a_test_40)));
end