function [L, num] = mysegmentation(BW)
assert(islogical(BW), 'Input must be logical.');
[m,n] = size(BW);
L = zeros(m,n,'uint32');
num = 0;
dirs = [-1 -1; -1 0; -1 1; 0 -1; 0 1; 1 -1; 1 0; 1 1];
for i = 1:m
    for j = 1:n
        if BW(i,j) && L(i,j)==0
            num = num + 1;
            stack = [i j];
            L(i,j) = num;
            while ~isempty(stack)
                p = stack(end,:); stack(end,:) = [];
                for d = 1:8
                    ii = p(1)+dirs(d,1);
                    jj = p(2)+dirs(d,2);
                    if ii>=1 && ii<=m && jj>=1 && jj<=n
                        if BW(ii,jj) && L(ii,jj)==0
                            L(ii,jj) = num;
                            stack(end+1,:) = [ii jj]; 
                        end
                    end
                end
            end
        end
    end
end
end
