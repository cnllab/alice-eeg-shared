function [dat] = flip_betas(dat)

%% function [dat] = flip_betas(dat)
% takes a .betas subfield and promotes each sub-array to 
% a top-level array of the same name
% need to do this for plotting, stats etc.
% does the same thing if there is a 'likes' log-likelihood subfield

dat = ft_struct2double(dat);

beta_names = fieldnames(dat.betas);
for i = 1:length(beta_names);
	eval(sprintf('dat.beta_%s = dat.betas.%s;', beta_names{i}, beta_names{i}));
end

dat = rmfield(dat, 'betas');

if isfield(dat, 'likes');
    likes_names = fieldnames(dat.likes);
    for i = 1:length(likes_names)
        eval(sprintf('dat.like_%s = dat.likes.%s;', likes_names{i}, likes_names{i}));
    end
end

end
