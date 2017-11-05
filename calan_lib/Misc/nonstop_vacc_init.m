function nonstop_vacc_init(blk, varargin)
    % Usage: nonstop_acc_init(gcb, 'var')
    % Continouosly accumulate a vector.
    % 
    % Valid 'var' names are:
    % vec_len = vector size, it is set equal to the RAM delay
    % n_bits = bitwidth of output
    % bin_pt = binary point of output
    % quantization = flag: 1: Truncate, 2: Round (unbiased: +/- Inf)
    % overflow = flag: 1: Wrap, 2: Saturate, 3: Flag as error
    
    if same_state(blk, varargin{:}), return, end
    munge_block(blk, varargin{:});

    addr_width   = get_var('addr_width', varargin{:});
    arith_type   = get_var('arith_type', varargin{:});
    n_bits       = get_var('n_bits', varargin{:});
    bin_pt       = get_var('bin_pt', varargin{:});
    quantization = get_var('quantization', varargin{:});
    overflow     = get_var('overflow', varargin{:});

    delete_lines(blk);
    
    if n_bits == 0,
        clean_blocks(blk);
        set_param(blk,'AttributesFormatString','');
        save_state(blk, varargin{:});
        return;
    end
    
    if (n_bits < bin_pt),
        errordlg('Number of bits for output must be greater than binary point position.'); return; end
        
    % block generation
    reuse_block(blk, 'addr', 'xbsIndex_r4/Counter', ...
        'n_bits', num2str(addr_width), ...
        'bin_pt', '0', ...
        'Position', [345 55 365 75]);
        
    reuse_block(blk, 'on', 'simulink/Sources/In1', ...
        'Port', '1', ...
        'Position', [235 138 265 152]);

    reuse_block(blk, 'din', 'simulink/Sources/In1', ...
        'Port', '2', ...
        'Position', [235 233 265 247]);

    reuse_block(blk, 'we', 'simulink/Sources/In1', ...
        'Port', '3', ...
        'Position', [235 333 265 347]);

    reuse_block(blk, 'zero', 'xbsIndex_r4/Constant', ...
        'arith_type', num2str(arith_type), ...
        'n_bits', num2str(n_bits), ...
        'bin_pt', num2str(bin_pt), ...
        'Position', [305 191 325 209]);
            
    reuse_block(blk, 'on_mux', 'xbsIndex_r4/Mux', ...
        'Position', [345 118 370 282]);
            
    reuse_block(blk, 'ram', 'xbsIndex_r4/Single Port RAM', ...
        'depth', num2str(2^addr_width), ...
        'latency', num2str(2^addr_width), ...
        'Position', [395 -3 470 403]);

    reuse_block(blk, 'addsub', 'xbsIndex_r4/AddSub', ...
        'precision', 'User Defined', ...
        'arith_type', num2str(arith_type), ...
        'n_bits', num2str(n_bits), ...
        'bin_pt', num2str(bin_pt), ...
        'quantization', num2str(quantization), ...
        'overflow', num2str(overflow), ...
        'Position', [300 227 330 278]); 

    reuse_block(blk, 'inverter', 'xbsIndex_r4/Inverter', ...
        'Position', [305 323 325 337]);

    reuse_block(blk, 'logical', 'xbsIndex_r4/Logical', ...
        'logical_function', 'OR', ...
        'Position', [345 324 370 346]);

    reuse_block(blk, 'dout', 'simulink/Sinks/Out1', ...
        'Port', '1', ...
        'Position', [510 193 540 207]);

    annotation = sprintf('%d_%d, %s\n%s, %s', ...
        n_bits, bin_pt, arith_type, quantization, overflow);
    set_param(blk, 'AttributesFormatString', annotation);

    % add lines
    add_line(blk, 'addr/1',   'ram/1');
    add_line(blk, 'on/1',     'on_mux/1');
    add_line(blk, 'zero/1',   'on_mux/2');
    add_line(blk, 'on_mux/1', 'ram/2');
    add_line(blk, 'on/1', 'inverter/1');
    add_line(blk, 'inverter/1', 'logical/1');
    add_line(blk, 'we/1', 'logical/2');
    add_line(blk, 'logical/1', 'ram/3');
    add_line(blk, 'din/1', 'addsub/1');
    add_line(blk, 'ram/1', 'addsub/2');
    add_line(blk, 'addsub/1', 'on_mux/3');
    add_line(blk, 'ram/1', 'dout/1');

    clean_blocks(blk);

    % Save and back-populate mask parameter values
    save_state(blk, varargin{:});

