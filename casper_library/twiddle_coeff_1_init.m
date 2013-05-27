function twiddle_coeff_1_init(blk, varargin)

  clog('entering twiddle_coeff_0_init',{'trace', 'twiddle_coeff_0_init_debug'});

  defaults = { ...
    'n_inputs', 2, ...
    'input_bit_width', 18, ...
    'add_latency', 1, ...
    'mult_latency', 2, ...
    'bram_latency', 2, ...
    'conv_latency', 2, ...
    'async', 'off'};

  if same_state(blk, 'defaults', defaults, varargin{:}), return, end
  check_mask_type(blk, 'twiddle_coeff_1');
  munge_block(blk, varargin{:});

  delete_lines(blk);

  n_inputs        = get_var('n_inputs', 'defaults', defaults, varargin{:});
  input_bit_width = get_var('input_bit_width', 'defaults', defaults, varargin{:});
  add_latency     = get_var('add_latency', 'defaults', defaults, varargin{:});
  bram_latency    = get_var('bram_latency', 'defaults', defaults, varargin{:});
  mult_latency    = get_var('mult_latency', 'defaults', defaults, varargin{:});
  conv_latency    = get_var('conv_latency', 'defaults', defaults, varargin{:});
  async           = get_var('async', 'defaults', defaults, varargin{:});

  if n_inputs == 0,
    clean_blocks(blk);
    save_state(blk, 'defaults', defaults, varargin{:});
    clog('exiting twiddle_coeff_1_init', {'trace', 'twiddle_coeff_1_init_debug'});
    return;
  end
  
  reuse_block(blk, 'ai', 'built-in/Inport');
  set_param([blk,'/ai'], ...
          'Port', sprintf('1'), ...
          'Position', sprintf('[50 108 80 122]'));

  reuse_block(blk, 'bi', 'built-in/Inport');
  set_param([blk,'/bi'], ...
          'Port', sprintf('2'), ...
          'Position', sprintf('[50 223 80 237]'));

  reuse_block(blk, 'sync_in', 'built-in/Inport');
  set_param([blk,'/sync_in'], ...
          'Port', sprintf('3'), ...
          'Position', sprintf('[50 333 80 347]'));

  reuse_block(blk, 'munge_in', 'casper_library_flow_control/munge');
  set_param([blk,'/munge_in'], ...
          'divisions', 'n_inputs*2', ...
          'div_size', 'repmat(input_bit_width, n_inputs*2, 1)', ...
          'order', '[[0:2:(n_inputs-1)*2],[1:2:(n_inputs-1)*2+1]]', ...
          'Position', [100 219 140 241]);

  reuse_block(blk, 'delay0', 'xbsIndex_r4/Delay');
  set_param([blk,'/delay0'], ...
          'latency', sprintf('mult_latency+add_latency+bram_latency+conv_latency'), ...
          'reg_retiming', sprintf('on'), ...
          'Position', sprintf('[250 106 285 124]'));

  reuse_block(blk, 'bus_expand', 'casper_library_flow_control/bus_expand');
  set_param([blk,'/bus_expand'], ...
          'mode', 'divisions of equal size', ...
          'outputNum', '2', ...
          'outputWidth', 'input_bit_width*n_inputs', ...
          'outputBinaryPt', '0', ...
          'outputArithmeticType', '0', ...
          'Position', [160 191 210 269]);

  reuse_block(blk, 'negate_real', 'xbsIndex_r4/Negate');
  set_param([blk,'/negate_real'], ... %TODO bus_negate
          'precision', sprintf('User Defined'), ...
          'arith_type', sprintf('Signed  (2''s comp)'), ...
          'n_bits', sprintf('input_bit_width'), ...
          'bin_pt', sprintf('input_bit_width-1'), ...
          'latency', sprintf('mult_latency+add_latency+bram_latency+conv_latency'), ...
          'Position', sprintf('[235 195 300 225]'));

  reuse_block(blk, 'delay1', 'xbsIndex_r4/Delay');
  set_param([blk,'/delay1'], ...
          'latency', sprintf('mult_latency+add_latency+bram_latency+conv_latency'), ...
          'reg_retiming', sprintf('on'), ...
          'Position', sprintf('[250 241 285 259]'));

  reuse_block(blk, 'bus_create', 'casper_library_flow_control/bus_create');
  set_param([blk,'/bus_create'], ...
          'inputNum', '2', ...
          'Position', sprintf('[335 190 380 270]'));

  reuse_block(blk, 'delay2', 'xbsIndex_r4/Delay');
  set_param([blk,'/delay2'], ...
          'latency', sprintf('mult_latency+add_latency+bram_latency+conv_latency'), ...
          'reg_retiming', sprintf('on'), ...
          'Position', sprintf('[250 331 285 349]'));

  reuse_block(blk, 'munge_out', 'casper_library_flow_control/munge');
  set_param([blk,'/munge_out'], ...
          'divisions', 'n_inputs*2', ...
          'div_size', 'repmat(input_bit_width, n_inputs*2, 1)', ...
          'order', 'reshape([[0:2:(n_inputs-1)*2],[1:2:(n_inputs-1)*2+1]], n_inputs*2, 1)', ...
          'Position', [400 219 440 241]);

  reuse_block(blk, 'ao', 'built-in/Outport');
  set_param([blk,'/ao'], ...
          'Port', sprintf('1'), ...
          'Position', sprintf('[465 108 495 122]'));

  reuse_block(blk, 'bwo', 'built-in/Outport');
  set_param([blk,'/bwo'], ...
          'Port', sprintf('2'), ...
          'Position', sprintf('[465 223 495 237]'));

  reuse_block(blk, 'sync_out', 'built-in/Outport');
  set_param([blk,'/sync_out'], ...
          'Port', sprintf('3'), ...
          'Position', sprintf('[465 333 495 347]'));

  add_line(blk,'ai/1','delay0/1', 'autorouting', 'on');
  add_line(blk,'bi/1','munge_in/1', 'autorouting', 'on');
  add_line(blk,'sync_in/1','delay2/1', 'autorouting', 'on');
  add_line(blk,'munge_in/1','bus_expand/1', 'autorouting', 'on');
  add_line(blk,'delay0/1','ao/1', 'autorouting', 'on');
  add_line(blk,'bus_expand/2','delay1/1', 'autorouting', 'on');
  add_line(blk,'bus_expand/1','negate_real/1', 'autorouting', 'on');
  add_line(blk,'negate_real/1','bus_create/2');
  add_line(blk,'delay1/1','bus_create/1');
  add_line(blk,'bus_create/1','munge_out/1', 'autorouting', 'on');
  add_line(blk,'delay2/1','sync_out/1', 'autorouting', 'on');
  add_line(blk,'munge_out/1','bwo/1', 'autorouting', 'on');
  
  if strcmp(async, 'on'),
    reuse_block(blk, 'dvi', 'built-in/Inport', ...
            'Port', '4', ...
            'Position', [50 396 80 414]);
    reuse_block(blk, 'delay3', 'xbsIndex_r4/Delay', ...
            'latency', 'mult_latency+add_latency+bram_latency+conv_latency', ...
            'reg_retiming', 'on', ...
            'Position', [250 396 285 414]);
    reuse_block(blk, 'dvo', 'built-in/Outport', ...
            'Port', '4', ...
            'Position', [465 398 495 412]);
    add_line(blk, 'dvi/1', 'delay3/1');
    add_line(blk, 'delay3/1', 'dvo/1');
  end

  clean_blocks(blk);

  save_state(blk, 'defaults', defaults, varargin{:});
  clog('exiting twiddle_coeff_0_init', {'trace','twiddle_coeff_0_init_debug'});
end % twiddle_coeff_1_init

