function err = q2s2(mpc, gen1, gen2, abr, ptdf)
[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
    VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
    TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;
[GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
    MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
    QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;

md = mpc;
df1 = ptdf(abr, md.gen(gen1, GEN_BUS));
df2 = ptdf(abr, md.gen(gen2, GEN_BUS));
adj = -0.1 / (df1 - df2);
md.gen(gen1, PG) = md.gen(gen1, PG) + adj;
md.gen(gen2, PG) = md.gen(gen2, PG) - adj;
mdres = runpf(md, mpoption('pf.alg', 'nr','verbose', 0));
dbrp = (mdres.branch(abr, PF) - mdres.branch(abr, PT) ...
    - (mpc.branch(abr, PF) - mpc.branch(abr, PT))) / 2;
err = (dbrp + 0.1) / -0.1;
end