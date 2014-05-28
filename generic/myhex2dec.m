function d = myhex2dec(h)
%HEX2DEC Convert hexadecimal string to decimal integer.
%   this is the hex2dec function from Matlab with some checking disabled
%   for faster performance

if iscellstr(h), h = char(h); end
if isempty(h), d = []; return, end

% Work in upper case. - disabled since upper case anyways
%h = upper(h);

[m,n]=size(h);

% Right justify strings and form 2-D character array.
if ~isempty(find((h==' ' | h==0),1))
  h = strjust(h);

  % Replace any leading blanks and nulls by 0.
  h(cumsum(h ~= ' ' & h ~= 0,2) == 0) = '0';
else
  h = reshape(h,m,n);
end

% Check for out of range values - disabled
% if any(any(~((h>='0' & h<='9') | (h>='A'&h<='F'))))
%    error(message('MATLAB:hex2dec:IllegalHexadecimal'));
% end

sixteen = 16;
p = fliplr(cumprod([1 sixteen(ones(1,n-1))]));
p = p(ones(m,1),:);

d = h <= 64; % Numbers
h(d) = h(d) - 48;

d =  h > 64; % Letters
h(d) = h(d) - 55;

d = sum(h.*p,2);