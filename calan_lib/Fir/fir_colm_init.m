function fir_colm_init(blk,varargin)

clog('entering fir_colm_init', 'trace');

% Declare any default values for arguments you might like.
defaults = {'n_inputs', 1, 'coeff', 0.1, 'add_latency', 2, 'mult_latency', 3, ...
    'coeff_bit_width', 25, 'coeff_bin_pt', 24, ...
    'first_stage_hdl', 'off', 'adder_imp', 'Fabric'};

check_mask_type(blk, 'fir_colm');
if same_state(blk, 'defaults', defaults, varargin{:}), return, end
clog('fir_col_init post same_state', 'trace');
munge_block(blk, varargin{:});
n_inputs = get_var('n_inputs','defaults', defaults, varargin{:});
coeff = get_var('coeff','defaults', defaults, varargin{:});
add_latency = get_var('add_latency','defaults', defaults, varargin{:});
mult_latency = get_var('mult_latency','defaults', defaults, varargin{:});
coeff_bit_width = get_var('coeff_bit_width','defaults', defaults, varargin{:});
coeff_bin_pt = get_var('coeff_bin_pt','defaults', defaults, varargin{:});
first_stage_hdl = get_var('first_stage_hdl','defaults', defaults, varargin{:});
adder_imp = get_var('adder_imp','defaults', defaults, varargin{:});

delete_lines(blk);

%default library state
if n_inputs == 0,
  clean_blocks(blk);
  save_state(blk, 'defaults', defaults, varargin{:});
  clog('exiting fir_colm_init', 'trace');
  return;
end

if length(coeff) ~= n_inputs,
  clog('number of coefficients must be the same as the number of inputs', {'fir_colm_init_debug', 'error'});
  error('number of coefficients must be the same as the number of inputs');
end

for i=1:n_inputs,
    reuse_block(blk, ['real',num2str(i)], 'built-in/inport','Port', num2str(i), 'Position', [30 i*80 60 15+80*i]);
    reuse_block(blk, ['fir_tapm',num2str(i)], 'fir_lib/fir_tapm');
     
    set_param([blk,'/fir_tapm',num2str(i)], 'Position', [180 i*160-70 230 50+160*i]);
    set_param([blk,'/fir_tapm',num2str(i)], 'latency', num2str(mult_latency));
    set_param([blk,'/fir_tapm',num2str(i)], 'factor', num2str(coeff(i)));
    set_param([blk,'/fir_tapm',num2str(i)], 'coeff_bit_width', num2str(coeff_bit_width));
    set_param([blk,'/fir_tapm',num2str(i)], 'coeff_bin_pt', num2str(coeff_bin_pt));
   
    reuse_block(blk, ['real_out',num2str(i)], 'built-in/outport', 'Position', [350 i*80 380 15+80*i], 'Port', num2str(i));
    
end

reuse_block(blk, 'real_sum', 'built-in/outport', 'Position', [600 10+20*n_inputs 630 30+20*n_inputs], 'Port', num2str(n_inputs+1));


if n_inputs > 1,
    reuse_block(blk, 'adder_tree1', 'casper_library_misc/adder_tree', ...
        'Position', [500 100 550 100+20*n_inputs], 'n_inputs', num2str(n_inputs),...
        'latency', num2str(add_latency), 'first_stage_hdl', first_stage_hdl, 'adder_imp', adder_imp);
    
    reuse_block(blk, 'c1', 'xbsIndex_r4/Constant', ...
        'explicit_period', 'on', 'Position', [450 100 480 110]);
  
    reuse_block(blk, 'term1','built-in/Terminator', 'Position', [600 100 615 115]);	
    add_line(blk, 'adder_tree1/1', 'term1/1');
    

    add_line(blk, 'c1/1', 'adder_tree1/1');
    add_line(blk,'adder_tree1/2','real_sum/1');
    
end

for i=1:n_inputs,
    add_line(blk,['real',num2str(i),'/1'],['fir_tapm',num2str(i),'/1']);
    
    add_line(blk,['fir_tapm',num2str(i),'/1'],['real_out',num2str(i),'/1']);
   
    if n_inputs > 1
        add_line(blk,['fir_tapm',num2str(i),'/2'],['adder_tree1/',num2str(i+1)]);
        
    else
        add_line(blk,['fir_tapm',num2str(i),'/2'],['real_sum/1']);
    end
end

% When finished drawing blocks and lines, remove all unused blocks.
clean_blocks(blk);

save_state(blk, 'defaults', defaults, varargin{:});

clog('exiting fir_colm_init', 'trace');
