%% Q2
%  ֻ����λ��27�Žڵ�ķ�������й����������������й��������䣬��ʹ��·27-28�ϵ��й����ʽ���0.1
fprintf('ֻ����λ��27�Žڵ�ķ�������й����������������й��������䣬��ʹ��·27-28�ϵ��й����ʽ���0.1\n');
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
% �����һ�ַ�����ѡȡһ�Խڵ㲢ͬʱ���ڽڵ��Ϸ�����Ե��й���������ʹ��·27-28�ϵ��й����ʽ���0.1
fprintf('�����һ�ַ�����ѡȡһ�Խڵ㲢ͬʱ���ڽڵ��Ϸ�����Ե��й���������ʹ��·27-28�ϵ��й����ʽ���0.1\n');
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