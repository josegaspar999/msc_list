function lst3= text_cat( lst1, lst2 )
lst3= lst1;
for i= 1:length(lst2)
    lst3{end+1}= lst2{i};
end
