function seq_minmax_init (blk, varargin)
% Usage: seq_minmax_init (gcb, 'var')
% Computes te minimum or maximum of a group of number that can be input,
% in parallel and sequentially. The number of sequential streams to compare
% is given by  the number of sequential accumulations.
%
% Valid 'var' names are:
% min_or_max = flag: 1: get minimum, 2: get maximum
% n_inputs = number of simultaneous (parallel) inputs (2^n_inputs)
% n_acc = number of sequential accumulations (2^n_acc)
% minmax_latency = latency of minmax block. The latency of the 
% whole system is given by: log2(n_inputs)+1

    if same_state(blk, varargin{:}), return, end
    munge_block(blk, varargin{:});

    min_or_max = get_var('min_or_max', varargin{:});
    log2_n_inputs = get_var('n_inputs', varargin{:});
    log2_n_acc = get_var('n_acc', varargin{:});
    minmax_latency = get_var('minmax_latency', varargin{:});
    %
    n_inputs = 2^log2_n_inputs;
    n_acc = 2^log2_n_acc;
    
    delete_lines(blk);

    %%% sync section
    reuse_block(blk, 'sync', 'simulink/Sources/In1', ...
        'Port', '1', ...
        'Position', [125 283 155 297]);
    %
    reuse_block(blk, 'counter', 'xbsIndex_r4/Counter', ...
        'n_bits', num2str(log2_n_acc), ...
        'bin_pt', '0', ...
        'rst', 'on', ...
        'Position', [185 260 245 320]);
    add_line(blk, 'sync/1', 'counter/1');
    %
    reuse_block(blk, 'zero', 'xbsIndex_r4/Constant', ...
        'const', '0', ...
        'arith_type', 'Unsigned', ...
        'n_bits', num2str(log2_n_acc), ...
        'bin_pt', '0', ...
        'Position', [265 242 290 268]);
    %
    reuse_block(blk, 'comparator', 'xbsIndex_r4/Relational', ...
        'mode', 'a=b', ...
        'Position', [315 239 370 306]); 
    add_line(blk, 'zero/1', 'comparator/1');
    add_line(blk, 'counter/1', 'comparator/2');
    %
    reuse_block(blk, 'sync_delay', 'xbsIndex_r4/Delay', ...
        'latency', num2str((log2_n_inputs)*minmax_latency), ...
        'position', [415 262 450 288]);
    add_line(blk, 'comparator/1', 'sync_delay/1');
    %
    %%% minmax tree section
    % input layer
    for i=1:n_inputs
    reuse_block(blk, strcat('in', num2str(i)), 'simulink/Sources/In1', ...
        'Port', num2str(i+1), ...
        'Position', [120 363+(i-1)*50 150 377+(i-1)*50]);
    end
    % comparator layers
    for i=1:log2_n_inputs
        for j=1:2^(log2_n_inputs-i)
            comp_name = strcat('minmax_', num2str(i),'_', num2str(j));
            reuse_block(blk, comp_name, 'calan_lib/minmax', ...
            'min_or_max', 'max', ...
            'latency', num2str(minmax_latency), ...
            'Position', [190+(i-1)*150 359+(j-1)*100 300+(i-1)*150 401+(j-1)*100]);
            if strcmp(min_or_max, 'min')
                reuse_block(blk, comp_name, 'calan_lib/minmax', ...
                    'min_or_max', 'min');
            else % if min_or_max = max
                reuse_block(blk, comp_name, 'calan_lib/minmax', ...
                    'min_or_max', 'max');
            end
            % connections
            if i==1
                add_line(blk, strcat('in',num2str(j*2-1), '/1'), strcat(comp_name, '/1'));
                add_line(blk, strcat('in',num2str(j*2  ), '/1'), strcat(comp_name, '/2'));
            else
                add_line(blk, strcat('minmax_', num2str(i-1), '_', num2str(j*2-1), '/1'), strcat(comp_name, '/1'));
                add_line(blk, strcat('minmax_', num2str(i-1), '_', num2str(j*2  ), '/1'), strcat(comp_name, '/2'));
            end
        end
    end


    %%% sequential minmax and output section
    reuse_block(blk, 'reg_minmax', 'calan_lib/minmax', ...
        'min_or_max', 'max', ...
        'latency', '0', ...
        'Position', [340+log2_n_inputs*150 359 450+log2_n_inputs*150 401]);
        if strcmp(min_or_max, 'min')
            reuse_block(blk, 'reg_minmax', 'calan_lib/minmax', ...
                'min_or_max', 'min');
        else % if min_or_max = max
            reuse_block(blk, 'reg_minmax', 'calan_lib/minmax', ...
                'min_or_max', 'max');
        end
    % n_inputs==1 border case
    if log2_n_inputs == 0
        add_line(blk, 'in1/1', 'reg_minmax/1');
    else
        add_line(blk, strcat('minmax_', num2str(log2_n_inputs), '_1/1'), 'reg_minmax/1');
    end
    %
    reuse_block(blk, 'mux', 'xbsIndex_r4/Mux', ...
        'Position', [470+log2_n_inputs*150 260 505+log2_n_inputs*150 340]);
    add_line(blk, 'sync_delay/1', 'mux/1');
    add_line(blk, 'reg_minmax/1', 'mux/2');
    % n_inputs==1 border case
    if log2_n_inputs == 0
        add_line(blk, 'in1/1', 'mux/3');    
    else
        add_line(blk, strcat('minmax_', num2str(log2_n_inputs), '_1/1'), 'mux/3');    
    end
    %
    reuse_block(blk, 'reg', 'xbsIndex_r4/Register', ...
        'Position', [555+log2_n_inputs*150  272 625+log2_n_inputs*150 328]); 
    add_line(blk, 'mux/1', 'reg/1');
    add_line(blk, 'reg/1', 'reg_minmax/2');
    %
    reuse_block(blk, 'valid', 'simulink/Sinks/Out1', ...
        'Port', '1', ...
        'Position', [655+log2_n_inputs*150 228 685+log2_n_inputs*150 242]);
        add_line(blk, 'sync_delay/1', 'valid/1');
    %
    reuse_block(blk, 'out', 'simulink/Sinks/Out1', ...
        'Port', '2', ...
        'Position', [655+log2_n_inputs*150 293 685+log2_n_inputs*150 307]);
        add_line(blk, 'reg/1', 'out/1');
    %
        
    clean_blocks(blk);

    save_state(blk, varargin{:});
