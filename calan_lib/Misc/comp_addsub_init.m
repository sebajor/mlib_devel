function comp_addsub_init(blk, varargin)
    % Usage: comp_addsub_init(gcb, 'var')
    % Add or substract two complex numbers of the same length.
    % 
    % Valid 'var' names are:
    % addsub = flag: 1: add two variables, 2: substract two variables
    % n_bits_in = bitwidth of real part of input (= imaginary part)
    % bin_pt_in = binary point of real part of input (= imaginary part)
    % n_bits_out = bitwidth of real part of output (= imaginary part)
    % bin_pt_out = binary point of real part of output (= imaginary part)
    % quantization = flag: 1: Truncate, 2: Round (unbiased: +/- Inf)
    % overflow = flag: 1: Wrap, 2: Saturate, 3: Flag as error
    % add_latency = latency of adder (= latency of whole block)

    if same_state(blk, varargin{:}), return, end
    munge_block(blk, varargin{:});

    addsub       = get_var('addsub', varargin{:});
    n_bits_in    = get_var('n_bits_in', varargin{:});
    bin_pt_in    = get_var('bin_pt_in', varargin{:});
    n_bits_out   = get_var('n_bits_out', varargin{:});
    bin_pt_out   = get_var('bin_pt_out', varargin{:});
    quantization = get_var('quantization', varargin{:});
    overflow     = get_var('overflow', varargin{:});
    add_latency  = get_var('add_latency', varargin{:});

    delete_lines(blk);
    
    if n_bits_in == 0 || n_bits_out == 0,
        clean_blocks(blk);
        set_param(blk,'AttributesFormatString','');
        save_state(blk, varargin{:});
        return;
    end
    
    if (n_bits_in < bin_pt_in),
        errordlg('Number of bits for input must be greater than binary point position.'); return; end
    if (n_bits_out < bin_pt_out),
        errordlg('Number of bits for output must be greater than binary point position.'); return; end

    % block generation
    reuse_block(blk, 'a', 'simulink/Sources/In1', ...
        'Port', '1', ...
        'Position', [110 103 140 117]);
        
    reuse_block(blk, 'b', 'simulink/Sources/In1', ...
        'Port', '2', ...
        'Position', [110 183 140 197]);
        
    reuse_block(blk, 'c_to_ri', 'casper_library_misc/c_to_ri', ...
        'n_bits', num2str(n_bits_in), ...
        'bin_pt', num2str(bin_pt_in), ...
        'Position', [175 89 215 131]);
        
    reuse_block(blk, 'c_to_ri1', 'casper_library_misc/c_to_ri', ...
        'n_bits', num2str(n_bits_in), ...
        'bin_pt', num2str(bin_pt_in), ...
        'Position', [175 169 215 211]);

    reuse_block(blk, 'AddSub', 'xbsIndex_r4/AddSub', ...
        'mode', num2str(addsub), ...
        'latency', num2str(add_latency), ...
        'n_bits', num2str(n_bits_out), ...
        'bin_pt', num2str(bin_pt_out), ...
        'quantization', num2str(quantization), ...
        'overflow', num2str(overflow), ...
        'Position', [260 90 300 130]);
        
    reuse_block(blk, 'AddSub1', 'xbsIndex_r4/AddSub', ...
        'mode', num2str(addsub), ...
        'latency', num2str(add_latency), ...
        'n_bits', num2str(n_bits_out), ...
        'bin_pt', num2str(bin_pt_out), ...
        'quantization', num2str(quantization), ...
        'overflow', num2str(overflow), ...
        'Position', [260 170 300 210]);
        
    reuse_block(blk, 'ri_to_c', 'casper_library_misc/ri_to_c', ...
        'Position', [325 71 365 229]);

    reuse_block(blk, 'out', 'simulink/Sinks/Out1', ...
        'Port', '1', ...
        'Position', [395 143 425 157]);
        
    annotation = sprintf('%d_%d * %d_%d ==> %d_%d\n%s, %s', ...
        n_bits_in, bin_pt_in, n_bits_in, bin_pt_in, n_bits_out, bin_pt_out, quantization, overflow);
    set_param(blk, 'AttributesFormatString', annotation);
        
    % add lines
    add_line(blk, 'a/1', 'c_to_ri/1');
    add_line(blk, 'b/1', 'c_to_ri1/1');
    add_line(blk, 'c_to_ri/1', 'AddSub/1');
    add_line(blk, 'c_to_ri/2', 'AddSub1/1');
    add_line(blk, 'c_to_ri1/1', 'AddSub/2');
    add_line(blk, 'c_to_ri1/2', 'AddSub1/2');
    add_line(blk, 'AddSub/1', 'ri_to_c/1');
    add_line(blk, 'AddSub1/1', 'ri_to_c/2');
    add_line(blk, 'ri_to_c/1', 'out/1');

    clean_blocks(blk)

    save_state(blk, varargin{:})
