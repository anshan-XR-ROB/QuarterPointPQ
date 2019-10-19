% run siftmat
function [] = run_deep1m(k, num_bits, num_bits_subspace, pretrain_pq_opq_qpq, search_pq_qpq)

%% Setting Evironment
addpath('../inria_fisher_v1/');
addpath('../vlfeat-0.9.21/toolbox');
vl_setup;
addpath('../pqcodes_matlab');
addpath ('../yael_v401/matlab');
%matlabpool;
%% Load Dataset
basedir = '../inria_fisher_v1/';
X_train = fvecs_read([basedir 'holiday_4096_base.fvecs']);
X_train = X_train';
size(X_train)
X_base = fvecs_read([basedir 'holiday_4096_base.fvecs']);
X_query = fvecs_read([basedir 'holiday_4096_query.fvecs']);
size(X_query)
%ids = ivecs_read ([basedir 'deep1M_groundtruth.ivecs']);
%ids_gnd = ids (1, :) + 1;

%% Setting Parameter 
d = size(X_train, 2);
N = 1001;     % number of elements to be returned
%k = 256;       % number of center in subspace
num_iter = 100; % Run 10 iterations only for quick demo. Run more iterations for better accuracy.  
%num_bits = 32; % number of bits per code (32, 64, 128)
%num_bits_subspace = 8; % number of bits per subspace (fixed);
M = num_bits / num_bits_subspace; % number of subquantizers to be used
min_distortion = 1e30;
trial = 1;
tpqlearn_vec = zeros(1, trial);
tpqencode_vec = zeros(1, trial);
tpqsearch_vec = zeros(1, trial);

for n_trial = 1:trial
    if pretrain_pq_opq_qpq == 'OPQ'
        sample_mean = mean(X_train, 1);
        X_train = bsxfun(@minus, X_train, sample_mean);
        R_opq_p = eigenvalue_allocation(single(X_train), M); 
        [centers_table_opq_p, code_opq_p, distortion_opq_p] = train_pq(X_train*R_opq_p, M, num_iter);
        fprintf('distortion_opq_p: %e\n\n', distortion_opq_p);
        if distortion_opq_p < min_distortion
            min_distortion = distortion_opq_p;
            R_init = R_opq_p;
        end 
        %[centers_table_init, code_init, distortion_init] = train_pq(X_train*R_init, M, num_iter / 2);
        %fprintf('opq-np: distortion_init: %e\n', distortion_init);
        %[centers_table_opq_np, code_opq_np, distortion_opq_np, R_opq_np] = train_opq_np(X_train, M, centers_table_init, R_init, num_iter / 2, 1, 'opq_distortion.mat');
        %fprintf('distortion_opq_np: %e\n', distortion_opq_np);
        X_train_pq = R_opq_p*X_train';
        %X_base = bsxfun(@minus, X_base, sample_mean');
        X_base_pq =R_opq_p*X_base;
        nbase = size(X_base_pq, 2);
        %X_query = bsxfun(@minus, X_query, sample_mean');
        X_query_pq = R_opq_p*X_query;
        nquery = size(X_query_pq,2);
    end

    if pretrain_pq_opq_qpq == 'QPQ'
        %% qpq
        [centers_table_init, code_init, distortion_init] = train_pq(X_train*R_init, M, num_iter / 2); 
        fprintf('opq-np: distortion_init: %e\n', distortion_init);
        [centers_table_qpq_np, distortion_qpq_np, R_qpq_np] = train_qpq_np(X_train, M, centers_table_init, R_init, num_iter / 2, 1, 'qpq_distortion.mat');
        fprintf('distortion_qpq_np: %e\n', distortion_qpq_np);
        X_train_pq = R_qpq_np*X_train';
        X_base_pq =R_qpq_np'*X_base;
        nbase = size(X_base_pq, 2);
        X_query_pq = R_qpq_np'*X_query;
        nquery = size(X_query_pq,2);
    end
    
    if pretrain_pq_opq_qpq == 'NPQ'
        X_train_pq = X_train';
        X_base_pq = X_base;
        nbase = size(X_base_pq, 2);
        X_query_pq = X_query;
        nquery = size(X_query_pq,2); 
    end
    
    if search_pq_qpq == 'NPQ'
        %% PQ search
        % Learn the PQ code structure
        t0 = cputime;
        pq = pq_new (M, X_train_pq); %PQ
        tpqlearn_vec(n_trial) = cputime - t0;
        % encode the database vectors
        t0 = cputime;
        cbase = pq_assign (pq, X_base_pq);
        tpqencode_vec(n_trial) = cputime - t0;
        %---[ perform the search and compare with the ground-truth ]---
        t0 = cputime;
        [ids_pqc, dis_pqc] = pq_search (pq, cbase, X_query_pq, N);
        tpqsearch_vec(n_trial) = cputime - t0;
        %     fprintf ('ADC learn  = %.3f s\n', tpqlearn);
        %     fprintf ('ADC encode = %.3f s\n', tpqencode);
        idx = ids_pqc;
        save(['idx_pq_' num2str(num_bits) '.mat'],'idx');        
    end
    if (search_pq_qpq == 'QPQ')
        %% QPQ search
        t0 = cputime;
        pq = qpq_new(M, X_train_pq);  % get centroid
        tpqlearn_vec(n_trial) = cputime - t0;
        
        t0 = cputime;
        [cbase, invertList, nonemptycell, centerDist] = qpq_assign (pq, X_base_pq);
        tpqencode_vec(n_trial) = cputime - t0;
        
        t0 = cputime;
        [ids_pqc] = qpq_search(pq, nbase, invertList, nonemptycell, centerDist, X_query_pq, N);
        tpqsearch_vec(n_trial) = cputime - t0;
        idx = ids_pqc;
        save(['idx_qpq_' num2str(num_bits) '.mat'],'idx');
    end
end

end

