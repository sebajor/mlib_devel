function vcm_init(blk, varargin)
%este bloque sirve para ...
defaults = {'fft_size', 2048, 'fft_outputs', 4, ...
    'n_shift', 24, ...
    'bits_data_in', 36, ...
    'bits_coef_im_re', 18, ...
    'bin_pt_coef_im_re', 15,...
    'num_bits', 18,...
    'bin_pts', 15};

check_mask_type(blk, 'vcm');

if same_state(blk, 'defaults', defaults, varargin{:}), return, end
clog('filt_init post same_state', 'trace');
munge_block(blk, varargin{:});

fft_size           = get_var('fft_size','defaults', defaults, varargin{:});
fft_outputs        = get_var('fft_outputs','defaults', defaults, varargin{:});
n_shift            = get_var('n_shift','defaults', defaults, varargin{:});
bits_data_in       = get_var('bits_data_in','defaults', defaults, varargin{:});
bits_coef_im_re    = get_var('bits_coef_im_re','defaults', defaults, varargin{:});
bin_pt_coef_im_re  = get_var('bin_pt_coef_im_re','defaults', defaults, varargin{:});
num_bits           = get_var('num_bits', 'defaults', defaults, varargin{:});
bin_pts            = get_var('bin_pts','defaults', defaults, varargin{:});

delete_lines(blk);

if fft_size  == 0,
    clean_blocks(blk);
    save_state(blk, 'defaults', defaults, varargin{:});  
    return; 
end
addr_width=log2(fft_size/fft_outputs); % the minnimum acceptable addr_width for this design is 9. For lower values edit mask and init function.
if  addr_width == 9,
    addr_width=10;
end
    

%inputs ports
reuse_block(blk, 'sync', 'built-in/inport', 'Port', '1', ...
    'Position', [220   118   250   132]);
reuse_block(blk, 'data_in', 'built-in/inport', 'Port', '2', ...
    'Position', [220   208   250   222]);

reuse_block(blk, 'spect_cnt', 'xbsIndex_r4/Counter', 'cnt_type', 'Count Limited', ...
    'operation','Up','start_count',num2str(0), 'cnt_by_val',num2str(1), ...
    'cnt_to', num2str(fft_size/fft_outputs-1),'arith_type', 'Unsigned','n_bits', num2str(addr_width), ...
    'bin_pt',num2str(0),'rst','on','explicit_period','on','period', num2str(1), ...
    'implementation','Fabric','Position', [370   264   410   306]);

reuse_block(blk, 'RE_BRAM', 'xps_library/Shared BRAM','arith_type', 'Unsigned', ...
    'addr_width',num2str(addr_width),'data_width',num2str(32),'Position', [485   276   565   334]);

reuse_block(blk, 'IM_BRAM', 'xps_library/Shared BRAM','arith_type', 'Unsigned', ...
    'addr_width',num2str(addr_width),'data_width',num2str(32),'Position', [485   416   565   474]);

reuse_block(blk, 'Constant', 'xbsIndex_r4/Constant', 'const',num2str(0), ...
    'arith_type', 'Boolean','explicit_period', 'on','Position', [385   315   410   335]);

reuse_block(blk, 'Constant1', 'xbsIndex_r4/Constant','const',num2str(0), ...
    'n_bits',num2str(32),'bin_pt',num2str(0),'explicit_period', 'on', ...
    'Position', [385   365   410   385]);


reuse_block(blk, 'Reinterpret', 'xbsIndex_r4/Reinterpret','force_arith_type','on', ...
    'arith_type', ['Signed  (2','''','s comp)'],'Position', [605   295   630   315]);

reuse_block(blk, 'Reinterpret1', 'xbsIndex_r4/Reinterpret','force_arith_type','on', ...
    'arith_type', ['Signed  (2','''','s comp)'],'Position', [605   436   630   454]);

reuse_block(blk, 'Shift1', 'xbsIndex_r4/Shift', 'shift_dir','Right', ...
    'shift_bits',num2str(n_shift),'precision','User Defined', ...
    'n_bits', num2str(num_bits), 'bin_pt', num2str(bin_pts), ...
    'quantization', 'Round  (unbiased: +/- Inf)', 'overflow', 'Saturate', ...
    'latency',num2str(1),'Position', [690   285   740   325]);
reuse_block(blk, 'Shift', 'xbsIndex_r4/Shift', 'shift_dir','Right', ...
    'shift_bits',num2str(n_shift),'precision','User Defined', ...
    'n_bits', num2str(num_bits), 'bin_pt', num2str(bin_pts), ...
    'quantization', 'Round  (unbiased: +/- Inf)', 'overflow', 'Saturate', ...
    'latency',num2str(1),'Position', [690   424   740   466]);


reuse_block(blk, 'cmult_dsp48e', 'casper_library_multipliers/cmult_dsp48e', ...
    'n_bits_a',num2str(bits_data_in/2),'bin_pt_a',num2str(bits_data_in/2-1), ...
    'n_bits_b',num2str(bits_coef_im_re),'bin_pt_b',num2str(bin_pt_coef_im_re), ...
    'full_precision','off','n_bits_c',num2str(bits_data_in/2), ...
    'bin_pt_c',num2str(bits_data_in/2-1),'quantization', 'Round  (unbiased: +/- Inf)', ...
    'overflow','Saturate','cast_latency',num2str(2),'Position', [795   201   885   334]);

reuse_block(blk, 'c_to_ri1', 'casper_library_misc/c_to_ri','n_bits',num2str(18), ...
    'bin_pt',num2str(17),'Position', [595   194   635   236]);

reuse_block(blk, 'ri_to_c1', 'casper_library_misc/ri_to_c', ...
    'Position', [975         244        1015         286]);

%outputs ports
reuse_block(blk, 'sync_out', 'built-in/outport', 'Port', '1', ...
    'Position', [1155         143        1185         157]);
reuse_block(blk, 'Out', 'built-in/outport', 'Port', '2', ...
    'Position', [1155         258        1185         272]);


%delays in sync path
reuse_block(blk, 'brams', 'xbsIndex_r4/Delay', 'latency',num2str(1), 'reg_retiming', 'on', ...
    'ShowName','off','Position', [505   114   520   136]);

reuse_block(blk, 'pre_shift', 'xbsIndex_r4/Delay', 'latency',num2str(1), 'reg_retiming', 'on', ...
    'ShowName','off','Position', [655   114   670   136]);

reuse_block(blk, 'shift', 'xbsIndex_r4/Delay', 'latency',num2str(1), 'reg_retiming', 'on', ...
    'ShowName','off','Position', [705   114   720   136]);

cl=get_param([blk,'/cmult_dsp48e'],'cast_latency');

reuse_block(blk, 'comp_mult', 'xbsIndex_r4/Delay', 'latency', ...
    num2str(4+str2num(cl)), 'reg_retiming', 'on', ...
    'ShowName','off','Position', [830   139   845   161]);

%delays in the data path

reuse_block(blk, 'brams_data', 'xbsIndex_r4/Delay', 'latency',num2str(1), 'reg_retiming', 'on', ...
    'ShowName','off','Position', [505   204   520   226]);
reuse_block(blk, 'pre_shift_datar', 'xbsIndex_r4/Delay', 'latency',num2str(1), 'reg_retiming', 'on', ...
    'ShowName','off','Position', [655   179   670   201]);
reuse_block(blk, 'pre_shift_datai', 'xbsIndex_r4/Delay', 'latency',num2str(1), 'reg_retiming', 'on', ...
    'ShowName','off','Position', [655   214   670   236]);
reuse_block(blk, 'shift_datar', 'xbsIndex_r4/Delay', 'latency',num2str(1), 'reg_retiming', 'on', ...
    'ShowName','off','Position', [705   179   720   201]);
reuse_block(blk, 'shift_datai', 'xbsIndex_r4/Delay', 'latency',num2str(1), 'reg_retiming', 'on', ...
    'ShowName','off','Position', [705   214   720   236]);

%delays in coeff line
reuse_block(blk, 'pre_shift_coefr', 'xbsIndex_r4/Delay', 'latency',num2str(1), 'reg_retiming', 'on', ...
    'ShowName','off','Position', [655   294   670   316]);
reuse_block(blk, 'pre_shift_coefi', 'xbsIndex_r4/Delay', 'latency',num2str(1), 'reg_retiming', 'on', ...
    'ShowName','off','Position', [655   434   670   456]);


%add lines between blocks

    
    %add lines in the sync path
add_line(blk,'sync/1','brams/1');
add_line(blk,'brams/1','pre_shift/1');
add_line(blk,'pre_shift/1','shift/1');
add_line(blk,'shift/1','comp_mult/1');
add_line(blk,'comp_mult/1','sync_out/1');


    %add line between sync in and counter
add_line(blk,'sync/1','spect_cnt/1');

    %add lines in the coef path

        %add line between cosntants and brams
add_line(blk,'Constant/1','RE_BRAM/3');
add_line(blk,'Constant/1','IM_BRAM/3');

add_line(blk,'Constant1/1','RE_BRAM/2');
add_line(blk,'Constant1/1','IM_BRAM/2');

        %add line between counter and brams adress input port
add_line(blk,'spect_cnt/1','RE_BRAM/1');
add_line(blk,'spect_cnt/1','IM_BRAM/1');

        %add lines between brams and reinterprets
add_line(blk,'RE_BRAM/1','Reinterpret/1');
add_line(blk,'IM_BRAM/1','Reinterpret1/1');

        %add lines between reinterprets and pre shift delays
add_line(blk,'Reinterpret/1','pre_shift_coefr/1');
add_line(blk,'Reinterpret1/1','pre_shift_coefi/1');

        %add lines between preshift delays and shifts.
add_line(blk,'pre_shift_coefr/1','Shift1/1');
add_line(blk,'pre_shift_coefi/1','Shift/1');

        %add lines between shifts and cmult_dsp48e
add_line(blk,'Shift1/1','cmult_dsp48e/3');
add_line(blk,'Shift/1','cmult_dsp48e/4');

    %add lines in the data path
    
        %add line between data_in inport and bram delay 
add_line(blk,'data_in/1','brams_data/1');

        %add line between delay bram and c to ri
add_line(blk,'brams_data/1','c_to_ri1/1');

        %add line between c to ri and pre shift re and im delays
add_line(blk,'c_to_ri1/1','pre_shift_datar/1');
add_line(blk,'c_to_ri1/2','pre_shift_datai/1');

        %add lines between pre shift delays and shift delays
add_line(blk,'pre_shift_datar/1','shift_datar/1');
add_line(blk,'pre_shift_datai/1','shift_datai/1');
      
        %add lines between shift data delays and cmult dsp48e
add_line(blk,'shift_datar/1','cmult_dsp48e/1');
add_line(blk,'shift_datai/1','cmult_dsp48e/2');

    %add lines in the post cmult path
    
        %add lines between cmult and ri to c1
add_line(blk,'cmult_dsp48e/1','ri_to_c1/1');
add_line(blk,'cmult_dsp48e/2','ri_to_c1/2');

        %add line between ri to c1 and data_out outport
add_line(blk,'ri_to_c1/1','Out/1');
      
clean_blocks(blk);

%set_param(blk,'AttributesFormatString',[num2str(num1),',',num2str(num2)]);

save_state(blk, 'defaults', defaults, varargin{:});
end
