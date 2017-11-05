function decim_init(blk, varargin)
%este bloque sirve para ...
if same_state(blk, varargin{:}), return, end
munge_block(blk, varargin{:});

defaults = {'dec_order', 8, 'n_inputs', 8, 'n_bits', 8, ...
    'coeff', 0.1, ...
    'quantization', 'Round  (unbiased: +/- Inf)', ...
    'add_latency', 1, 'mult_latency', 2, 'conv_latency', 2, ...
    'coeff_bit_width', 25, 'coeff_bin_pt', 24, ...
    'absorb_adders', 'on', 'adder_imp', 'DSP48'};

dec_order = get_var('dec_order', 'defaults', defaults, varargin{:});
n_inputs = get_var('n_inputs','defaults', defaults, varargin{:});
coeff = get_var('coeff', 'defaults', defaults, varargin{:});
n_bits = get_var('n_bits', 'defaults', defaults, varargin{:});
quantization = get_var('quantization', 'defaults', defaults, varargin{:});
add_latency = get_var('add_latency', 'defaults', defaults, varargin{:});
mult_latency = get_var('mult_latency', 'defaults', defaults, varargin{:});
conv_latency = get_var('conv_latency', 'defaults', defaults, varargin{:});
coeff_bit_width = get_var('coeff_bit_width', 'defaults', defaults, varargin{:});
coeff_bin_pt = get_var('coeff_bin_pt', 'defaults', defaults, varargin{:}); 
absorb_adders = get_var('absorb_adders', 'defaults', defaults, varargin{:});
adder_imp = get_var('adder_imp', 'defaults', defaults, varargin{:});
coeficientes=coeff;
%if dec_order ~= 2 || dec_order ~= 4 || dec_order ~= 8, error('Decimation order can only be 2,4 or 8'), end
delete_lines(blk);
for i=1:n_inputs,
    reuse_block(blk, ['in',num2str(i)], 'built-in/inport', ...
        'Position', [0 90*i 30 90*i+15], 'Port', num2str(i));    
end

reuse_block(blk, 'sync_in', 'built-in/inport', 'Port', num2str(n_inputs+1), ...
    'Position', [0    90*(n_inputs+1)    30    90*(n_inputs+1)+15]);
reuse_block(blk, 'sync_out', 'built-in/outport', 'Port', '1', ...
    'Position', [200+265    60    200+285    80]);
reuse_block(blk, 'out1', 'built-in/outport', 'Port', '2', ...
    'Position', [200+265    60+30    200+285    80+30]);
if dec_order == 8,
    reuse_block(blk, 'filtro1', 'filters_lib/filt_simple');
    %'n_inputs', n_inputs, ...
    %   'coeff', coeff, 'n_bits', n_bits, 'quantization', quantization, ...
    %   'add_latency', add_latency, 'mult_latency', mult_latency, ...
    %   'conv_latency', conv_latency, 'coeff_bit_width', coeff_bit_width, ...
    %   'coeff_bin_pt', coeff_bin_pt, 'absorb_adders', absorb_adders, ...
    %   'adder_imp', adder_imp, 'Position', [25    29    95    61]);
    
    set_param([blk,'/filtro1'],'n_inputs',num2str(n_inputs));
    set_param([blk,'/filtro1'],'coeff', mat2str(coeficientes));
    set_param([blk,'/filtro1'],'n_bits', num2str(n_bits));
    set_param([blk,'/filtro1'],'quantization', quantization);
    set_param([blk,'/filtro1'],'add_latency', num2str(add_latency));
    set_param([blk,'/filtro1'],'mult_latency', num2str(mult_latency));
    set_param([blk,'/filtro1'],'conv_latency', num2str(conv_latency));
    set_param([blk,'/filtro1'],'coeff_bit_width', num2str(coeff_bit_width));
    set_param([blk,'/filtro1'],'coeff_bin_pt', num2str(coeff_bin_pt));
    set_param([blk,'/filtro1'],'absorb_adders', absorb_adders);
    set_param([blk,'/filtro1'],'adder_imp', adder_imp);
    set_param([blk,'/filtro1'],'Position', [300    200    370    400]);
    for i=1:n_inputs,
        add_line(blk, ['in',num2str(i),'/1'], ['filtro1/',num2str(i)]);
    end
end   
if dec_order == 4,
    reuse_block(blk, 'filtro1', 'filters_lib/filt');
    set_param([blk,'/filtro1'],'n_inputs',num2str(n_inputs));
    set_param([blk,'/filtro1'],'coeff', mat2str(coeficientes));
    set_param([blk,'/filtro1'],'n_bits', num2str(n_bits));
    set_param([blk,'/filtro1'],'quantization', quantization);
    set_param([blk,'/filtro1'],'add_latency', num2str(add_latency));
    set_param([blk,'/filtro1'],'mult_latency', num2str(mult_latency));
    set_param([blk,'/filtro1'],'conv_latency', num2str(conv_latency));
    set_param([blk,'/filtro1'],'coeff_bit_width', num2str(coeff_bit_width));
    set_param([blk,'/filtro1'],'coeff_bin_pt', num2str(coeff_bin_pt));
    set_param([blk,'/filtro1'],'absorb_adders', absorb_adders);
    set_param([blk,'/filtro1'],'adder_imp', adder_imp);
    set_param([blk,'/filtro1'],'Position', [300    200    370    400]);
    
    
    reuse_block(blk, 'out2', 'built-in/outport', 'Port', '3', ...
    'Position', [200+265    60+60    200+285    80+60]);
    add_line(blk, ['filtro1/',num2str(3)], 'out2/1');
    for i=1:n_inputs,
        add_line(blk, ['in',num2str(i),'/1'], ['filtro1/',num2str(i)]);
    end
end


if dec_order == 2,
    reuse_block(blk, 'filtro1', 'filters_lib/filt');
    reuse_block(blk, 'filtro2', 'filters_lib/filt');
    
    
    set_param([blk,'/filtro1'],'n_inputs',num2str(n_inputs));
    set_param([blk,'/filtro1'],'coeff', mat2str(coeficientes));
    set_param([blk,'/filtro1'],'n_bits', num2str(n_bits));
    set_param([blk,'/filtro1'],'quantization', quantization);
    set_param([blk,'/filtro1'],'add_latency', num2str(add_latency));
    set_param([blk,'/filtro1'],'mult_latency', num2str(mult_latency));
    set_param([blk,'/filtro1'],'conv_latency', num2str(conv_latency));
    set_param([blk,'/filtro1'],'coeff_bit_width', num2str(coeff_bit_width));
    set_param([blk,'/filtro1'],'coeff_bin_pt', num2str(coeff_bin_pt));
    set_param([blk,'/filtro1'],'absorb_adders', absorb_adders);
    set_param([blk,'/filtro1'],'adder_imp', adder_imp);
    set_param([blk,'/filtro1'],'Position', [300    200    370    400]);
    
    set_param([blk,'/filtro2'],'n_inputs',num2str(n_inputs));
    set_param([blk,'/filtro2'],'coeff', mat2str(coeficientes));
    set_param([blk,'/filtro2'],'n_bits', num2str(n_bits));
    set_param([blk,'/filtro2'],'quantization', quantization);
    set_param([blk,'/filtro2'],'add_latency', num2str(add_latency));
    set_param([blk,'/filtro2'],'mult_latency', num2str(mult_latency));
    set_param([blk,'/filtro2'],'conv_latency', num2str(conv_latency));
    set_param([blk,'/filtro2'],'coeff_bit_width', num2str(coeff_bit_width));
    set_param([blk,'/filtro2'],'coeff_bin_pt', num2str(coeff_bin_pt));
    set_param([blk,'/filtro2'],'absorb_adders', absorb_adders);
    set_param([blk,'/filtro2'],'adder_imp', adder_imp);
    set_param([blk,'/filtro2'],'Position', [300    200+300    370    400+300]);
    for i=1:n_inputs,
        reuse_block(blk, ['regis',num2str(i)], 'xbsIndex_r4/Register', ...
        'Position', [0+60 90*i 30+60 90*i+15]);
    end
    
    reuse_block(blk, 'out2', 'built-in/outport', 'Port', '3', ...
    'Position', [200+265    60+60    200+285    80+60]);
    reuse_block(blk, 'out3', 'built-in/outport', 'Port', '4', ...
    'Position', [200+265    60+90+300    200+285    80+90+300]);
    reuse_block(blk, 'out4', 'built-in/outport', 'Port', '5', ...
    'Position', [200+265    60+120+300    200+285    80+120+300]);
    add_line(blk, ['filtro1/',num2str(3)], 'out3/1');
    add_line(blk, ['filtro2/',num2str(2)], 'out2/1');
    add_line(blk, ['filtro2/',num2str(3)], 'out4/1');
    
    add_line(blk, ['regis',num2str(3),'/1'], ['filtro2/',num2str(1)]);
    add_line(blk, ['regis',num2str(4),'/1'], ['filtro2/',num2str(2)]);
    add_line(blk, ['regis',num2str(5),'/1'], ['filtro2/',num2str(3)]);
    add_line(blk, ['regis',num2str(6),'/1'], ['filtro2/',num2str(4)]);
    add_line(blk, ['regis',num2str(7),'/1'], ['filtro2/',num2str(5)]);
    add_line(blk, ['regis',num2str(8),'/1'], ['filtro2/',num2str(6)]);
    add_line(blk, 'in1/1', ['filtro2/',num2str(7)]);
    add_line(blk, 'in2/1', ['filtro2/',num2str(8)]);
    add_line(blk, 'sync_in/1', ['filtro2/',num2str(n_inputs+1)]);
    for i=1:n_inputs,
        add_line(blk, ['in',num2str(i),'/1'], ['regis',num2str(i),'/1']);
        add_line(blk, ['regis',num2str(i),'/1'], ['filtro1/',num2str(i)]);
    end
        
end

add_line(blk, 'sync_in/1', ['filtro1/',num2str(n_inputs+1)]);
add_line(blk, ['filtro1/',num2str(2)], 'out1/1');
add_line(blk, ['filtro1/',num2str(1)], 'sync_out/1');


clean_blocks(blk);

set_param(blk,'AttributesFormatString',['dec_order',num2str(dec_order),',',num2str(length(coeff)),' taps']);

save_state(blk, varargin{:});
end
