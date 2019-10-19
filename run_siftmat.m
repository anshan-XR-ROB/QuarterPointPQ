% run siftmat
%% Setting Evironment
addpath('../vlfeat-0.9.21/toolbox');
vl_setup;
addpath('../pqcodes_matlab');
addpath ('../yael_v401/matlab');
%% Load Dataset
load('data/sift.mat');
X_train = Xtrain;

matlabpool;
%% Setting Parameter 
d = size(X_train, 2);
N = 1000;     % number of elements to be returned
k = 256;       % number of center in subspace
num_iter = 2; % Run 10 iterations only for quick demo. Run more iterations for better accuracy.  
num_bits = 32; % number of bits per code (32, 64, 128)
num_bits_subspace = 8; % number of bits per subspace (fixed);
M = num_bits / num_bits_subspace; % number of subquantizers to be used
min_distortion = 1e30;
R_init = eye(d);

%% opq (non-parametric)
%[centers_table_init, code_init, distortion_init] = train_pq(X_train*R_init, M, num_iter / 2); % Use half iteration for init, and half for opq_np.
                                                                                                % The total num_iter equals to the competitors.
%fprintf('opq-np: distortion_init: %e\n', distortion_init);

%% opq
%[centers_table_opq_np, code_opq_np, distortion_opq_np, R_opq_np] = train_opq_np(X_train, M, centers_table_init, R_init, num_iter / 2, 1, 'opq_distortion.mat');
%fprintf('distortion_opq_np: %e\n', distortion_opq_np);
%save('workplace_opq_mnist_iter50.mat', 'centers_table_opq_np', 'code_opq_np', 'distortion_opq_np', 'R_opq_np');

% %% spq
% [centers_table_spq_np, distortion_spq_np, R_spq_np] = train_spq_np(X_train, M, centers_table_init, R_init, num_iter / 2, 1, 'spq_distortion.mat');
% fprintf('distortion_opq_np: %e\n', distortion_spq_np);
% save('workplace_spq.mat', 'centers_table_spq_np', 'distortion_spq_np', 'R_spq_np');

% load('workplace_opq_mnist.mat');
%% OPQ data process
%centers_table_init = centers_table_opq_np;
%R_init = R_opq_np;
%X_train = R_opq_np*X_train';
%X_base =R_opq_np*X_train;
%nbase = size(X_base, 2);
%X_query = R_opq_np*X_train(:,1:1000);
%nquery = size(X_query,2);
%ids_gnd = [1:nquery];
X_train = X_train';
X_base =X_train;
nbase = size(X_base, 2);
X_query = X_train(:,1:1000);
nquery = size(X_query,2);
ids_gnd = [1:nquery];


 %% PQ search
 % Learn the PQ code structure
 %tic;
 t0 = cputime; 
% pq = pq_new (M, X_train'); %PQ
 pq = pq_new (M, X_train);    %OPQ
 tpqlearn = cputime - t0;
 % encode the database vectors
 t0 = cputime;
 cbase = pq_assign (pq, X_base);
 tpqencode = cputime - t0;
 %---[ perform the search and compare with the ground-truth ]---
 t0 = cputime;
 [ids_pqc, dis_pqc] = pq_search (pq, cbase, X_query, k);
 tpq = cputime-t0;
 fprintf ('ADC learn  = %.3f s\n', tpqlearn);
 fprintf ('ADC encode = %.3f s\n', tpqencode);
 fprintf ('ADC search = %.3f s  for %d query vectors in a database of %d vectors\n', tpq, nquery, size(X_base,2));
 % compute search statistics 
 pq_test_compute_stats

 
t0 = cputime;
pq = qpq_new(M, X_train);  % get centroid     
tpqlearn = cputime - t0;
t0 = cputime;
[cbase, invertList, nonemptycell, centerDist] = qpq_assign (pq, X_base);
tpqencode = cputime-t0;
t0 = cputime;;
[ids_pqc] = qpq_search(pq, nbase, invertList, nonemptycell, centerDist, X_query, N);
tpq = cputime-t0;
fprintf ('ADC learn  = %.3f s\n', tpqlearn);
fprintf ('ADC encode = %.3f s\n', tpqencode);
fprintf ('ADC search = %.3f s  for %d query vectors in a database of %d vectors\n', tpq, nquery, size(X_base,2));
pq_test_compute_stats

matlabpool close;
