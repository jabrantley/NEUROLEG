function newobj=copyobj(this)
newobj=feval(class(this));
props=properties(this);
for i=1:length(props)
    newobj.(props{i})=this.(props{i});
end
end