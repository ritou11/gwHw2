[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
    VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
    TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;
[GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
    MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
    QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
mpc = case30();
%% Watch case30
n_pq = sum(mpc.bus(:, BUS_TYPE) == 1);
n_pv = sum(mpc.bus(:, BUS_TYPE) == 2);
n_ref = sum(mpc.bus(:, BUS_TYPE) == 3);

fprintf('Bus Type: PQ: %d, PV: %d, REF: %d\n', n_pq, n_pv, n_ref);
%% pf case30
res = runpf(mpc, mpoption('pf.alg', 'nr', 'verbose', 0), 'meta/case30pf_nr.log', 'meta/case30pf_nr');
%% PTDF
mp_ptdf = makePTDF(res);
exp_ptdf = expPTDF(res);
fprintf('Calc error: %s\n', norm(mp_ptdf-exp_ptdf));
%% Q1
branchp = @(x)(x.branch(:, PF) - x.branch(:, PT)) / 2;
org_brp = branchp(res);
%% 当位于2号节点的发电机有功出力减小0.1、1与10时
fprintf('当位于2号节点的发电机有功出力减小0.1、1与10时\n');
%% -0.1
fig = figure; hold on;
fprintf('-0.1 Error: %.2f%%\n', q1s1(res, exp_ptdf, 0.1) * 100);
%% -1
fprintf('-1 Error: %.2f%%\n', q1s1(res, exp_ptdf, 1) * 100);
%% -10
fprintf('-10 Error: %.2f%%\n', q1s1(res, exp_ptdf, 10) * 100);
legend('-0.1','-1','-10');
saveas(fig, 'meta/q1s1.png');
close(fig);
%% 当位于2号节点的发电机有功出力减小0.1、1与10且位于13号节点的发电机有功出力相应增加0.1、1与10以使系统总调整量为0时。
fprintf('当位于2号节点的发电机有功出力减小0.1、1与10且位于13号节点的发电机有功出力相应增加0.1、1与10以使系统总调整量为0时\n');
%% -0.1
fig = figure; hold on;
fprintf('-0.1 Error: %.2f%%\n', q1s2(res, exp_ptdf, 0.1) * 100);
%% -1
fprintf('-1 Error: %.2f%%\n', q1s2(res, exp_ptdf, 1) * 100);
%% -10
fprintf('-10 Error: %.2f%%\n', q1s2(res, exp_ptdf, 10) * 100);
legend('-0.1','-1','-10');
saveas(fig, 'meta/q1s2.png');
close(fig);
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
