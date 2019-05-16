function comp_adder_tree_init(blk, varargin)
    % Usage: comp_addsub_tree_init(gcb, 'var')
    % Add or substract multiple complex numbers of the same length.
    % 
    % Valid 'var' names are:
    % n_inputs = number of complex inputs
    % n_bits = bitwidth of real part of input (= imaginary part)
    % bin_pt = binary point of real part of input (= imaginary part)
    % add_latency = latency of adder (= latency of whole block)

    if same_state(blk, varargin{:}), return, end
    munge_block(blk, varargin{:});

    n_inputs    = get_var('n_inputs', varargin{:});
    n_bits      = get_var('n_bits', varargin{:});
    bin_pt      = get_var('bin_pt', varargin{:});
    add_latency = get_var('add_latency', varargin{:});

    delete_lines(blk);
    
    if n_bits == 0,
        clean_blocks(blk);
        set_param(blk,'AttributesFormatString','');
        save_state(blk, varargin{:});
        return;
    end
    
    if (n_bits < bin_pt),
        errordlg('Number of bits for input must be greater than binary point position.'); return; end

    % block generation (static blocks)
    reuse_block(blk, 'adder_tree', 'casper_library_misc/adder_tree', ...
        'n_inputs', num2str(n_inputs), ...
        'latency', num2str(add_latency), ...
        'Position', [290 -38 355 138]);

    reuse_block(blk, 'adder_tree1', 'casper_library_misc/adder_tree', ...
        'n_inputs', num2str(n_inputs), ...
        'latency', num2str(add_latency), ...
        'Position', [290 192 355 368]);
    
    reuse_block(blk, 'Constant', 'xbsIndex_r4/Constant', ...
        'const', '0', ...
        'arith_type', 'Boolean', ...
        'explicit_period', 1, ...
        'Position', [195 -33 250 -7]);

    reuse_block(blk, 'Constant1', 'xbsIndex_r4/Constant', ...
        'const', '0', ...
        'arith_type', 'Boolean', ...
        'explicit_period', 1, ...
        'Position', [195 197 250 223]);

    reuse_block(blk, 'Terminator', 'simulink/Sinks/Terminator', ...
        'Position', [390 -5 410 15]);

    reuse_block(blk, 'Terminator1', 'simulink/Sinks/Terminator', ...
        'Position', [390 225 410 245]);

    reuse_block(blk, 'ri_to_c', 'casper_library_misc/ri_to_c', ...
        'Position', [490 144 530 186]);

    reuse_block(blk, 'dout', 'simulink/Sinks/Out1', ...
        'Port', '1', ...
        'Position', [575 158 605 172]);
    
    % add lines (static blocks)
    add_line(blk, 'Constant/1', 'adder_tree/1');
    add_line(blk, 'Constant1/1', 'adder_tree1/1');
    add_line(blk, 'adder_tree/1', 'Terminator/1');
    add_line(blk, 'adder_tree1/1', 'Terminator1/1');
    add_line(blk, 'adder_tree/2', 'ri_to_c/1');
    add_line(blk, 'adder_tree1/2', 'ri_to_c/2');
    add_line(blk, 'ri_to_c/1', 'dout/1');

    % block generation (dynamic blocks)
    in_pos = [-60 18 -30 32];
    ctori_pos = [15 4 55 46];
    in_incr = [0 85 0 85];
    for i=1:n_inputs
        reuse_block(blk, strcat('din', num2str(i)), 'simulink/Sources/In1', ...
            'Port', num2str(i), ...
            'Position', in_pos + (i-1)*in_incr);
        
        reuse_block(blk, strcat('c_to_ri', num2str(i)), 'casper_library_misc/c_to_ri', ...
            'n_bits', num2str(n_bits), ...
            'bin_pt', num2str(bin_pt), ...
            'Position', ctori_pos + (i-1)*in_incr);
        
        % add lines (dynamic blocks)
        add_line(blk, strcat('din', num2str(i),'/1'), strcat('c_to_ri', num2str(i),'/1'))
        add_line(blk, strcat('c_to_ri', num2str(i),'/1'), strcat('adder_tree/', num2str(i+1)))
        add_line(blk, strcat('c_to_ri', num2str(i),'/2'), strcat('adder_tree1/', num2str(i+1)))
    end
    
    annotation = sprintf('%d_%d', n_bits, bin_pt);
    set_param(blk, 'AttributesFormatString', annotation);
        
    clean_blocks(blk)

    save_state(blk, varargin{:})
