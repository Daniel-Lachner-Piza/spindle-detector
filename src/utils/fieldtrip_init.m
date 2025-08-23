function fieldtrip_init(cfg)
cd(cfg.workspacePath)
addpath(genpath(cfg.workspacePath));
addpath(cfg.ftPath);
ft_defaults;
end
