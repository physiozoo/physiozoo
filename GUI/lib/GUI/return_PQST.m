%%
function [P, Q, S, T, R] = return_PQST(PQRST_position, time_samples)

P = PQRST_position.P(~isnan(PQRST_position.P)) + time_samples;
Q = PQRST_position.QRSon(~isnan(PQRST_position.QRSon)) + time_samples;
S = PQRST_position.QRSoff(~isnan(PQRST_position.QRSoff)) + time_samples;
T = PQRST_position.T(~isnan(PQRST_position.T)) + time_samples;

R = PQRST_position.qrs(~isnan(PQRST_position.qrs)) + time_samples;