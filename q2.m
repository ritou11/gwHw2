%% Q2
%  只调节位于27号节点的发电机的有功出力，其他机组有功出力不变，以使线路27-28上的有功功率降低0.1
fprintf('只调节位于27号节点的发电机的有功出力，其他机组有功出力不变，以使线路27-28上的有功功率降低0.1\n');
node = 27;
target = find(res.gen(:, GEN_BUS) == node); % find the gen
abr = find((res.branch(:, F_BUS) == 27 & res.branch(:, T_BUS) == 28) ...
    | (res.branch(:, F_BUS) == 28 & res.branch(:, T_BUS) == 27));
adjust_amount = - 0.1 / exp_ptdf(abr, node);
md = res;
md.gen(target, PG) = md.gen(target, PG) + adjust_amount; 
mdres = runpf(md, mpoption('pf.alg', 'nr','verbose', 0));
dbrp = (mdres.branch(abr, PF) - mdres.branch(abr, PT) ...
    - (res.branch(abr, PF) - res.branch(abr, PT))) / 2;
err = (dbrp + 0.1) / -0.1;
fprintf('Error: %.2f%%\n', err * 100);
% 请设计一种方案，选取一对节点并同时调节节点上发电机对的有功出力，以使线路27-28上的有功功率降低0.1
fprintf('请设计一种方案，选取一对节点并同时调节节点上发电机对的有功出力，以使线路27-28上的有功功率降低0.1\n');
md = res;
[maxdf, maxdfgen] = max(exp_ptdf(abr, md.gen(:, GEN_BUS)));
[mindf, mindfgen] = min(exp_ptdf(abr, md.gen(:, GEN_BUS)));
adj = -0.1 / (maxdf - mindf);
md.gen(maxdfgen, PG) = md.gen(maxdfgen, PG) + adj;
md.gen(mindfgen, PG) = md.gen(mindfgen, PG) - adj;
mdres = runpf(md, mpoption('pf.alg', 'nr','verbose', 0));
dbrp = (mdres.branch(abr, PF) - mdres.branch(abr, PT) ...
    - (res.branch(abr, PF) - res.branch(abr, PT))) / 2;
err = (dbrp + 0.1) / -0.1;
fprintf('Error: %.2f%%\n', err * 100);