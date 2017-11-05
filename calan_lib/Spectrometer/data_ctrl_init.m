function data_ctrl_init(blk, varargin)
%este bloque sirve para ...
defaults = {'fft_size', 2048, ...
			'fft_outputs', 4, ...
    	    'accum', 1};

check_mask_type(blk, 'data_ctrl');

if same_state(blk, 'defaults', defaults, varargin{:}), return, end
clog('data_ctrl_init post same_state', 'trace');
munge_block(blk, varargin{:});

fft_size           = get_var('fft_size', 'defaults', defaults, varargin{:});
fft_outputs        = get_var('fft_outputs', 'defaults', defaults, varargin{:});
accum              = get_var('accum', 'defaults', defaults, varargin{:});


delete_lines(blk);

if fft_size  == 0,
    clean_blocks(blk);
    save_state(blk, 'defaults', defaults, varargin{:});  
    return; 
end

if accum == 1
    
	    % Inputs ports
    reuse_block(blk, 'valid', 'built-in/inport', 'Port', '1', ...
        'Position', [-610    98  -580   112]);

        % Constants

    reuse_block(blk, 'Constant', 'built-in/Constant', 'Value', '0', ...
	    'SampleTime', 'inf', 'OutDataTypeStr','Inherit: Inherit from ''Constant value''', ...
	    'ShowName', 'off', 'Position', [-615   -17  -580    -3]);

        % Software registers
    reuse_block(blk, 'reading', 'xps_library/software register', ...
	    'io_dir', 'From Processor', 'Position', [-545   -30  -460    10]);

    reuse_block(blk, 'mem_select', 'xps_library/software register', 'numios', '1', ...
	    'io_delay', '0', 'arith_type1', 'Boolean', 'io_dir','To Processor', 'Position', ...
        [260   235   345   275]);

        % Go to
    reuse_block(blk, 'goto_v0', 'built-in/goto','GotoTag', 'valid', ...
        'ShowName', 'off', 'Position', [-415   132  -350   148])

    reuse_block(blk, 'goto_w0', 'built-in/goto','GotoTag', 'we', ...
        'ShowName', 'off', 'Position', [335    99   415   111])

        % From
    reuse_block(blk, 'from_v0', 'built-in/from','GotoTag', 'valid', ...
        'ShowName', 'off', 'Position', [-475   -97  -435   -83])

    reuse_block(blk, 'from_v1', 'built-in/from','GotoTag', 'valid', ...
        'ShowName', 'off', 'Position', [185    53   225    67])

    reuse_block(blk, 'from_v2', 'built-in/from','GotoTag', 'valid', ...
        'ShowName', 'off', 'Position', [185   163   225   177])

    reuse_block(blk, 'from_w0', 'built-in/from','GotoTag', 'we', ...
        'ShowName', 'off', 'Position', [-215   134  -150   146])

        % Inverter
    reuse_block(blk, 'Not0', 'xbsIndex_r4/Inverter','en', 'off', ...
        'ShowName', 'off', 'latency', '0', 'Position', [-375  -101  -350   -79])

    reuse_block(blk, 'Not1', 'xbsIndex_r4/Inverter','en', 'off', ...
        'ShowName', 'off', 'latency', '0', 'Position', [-375   -21  -350     1])

    reuse_block(blk, 'Not2', 'xbsIndex_r4/Inverter','en', 'off', ...
        'ShowName', 'off', 'latency', '0', 'Position', [145   174   170   196])

        % Logical
    reuse_block(blk, 'Logical0', 'xbsIndex_r4/Logical', 'logical_function', 'AND', ...
	    'inputs', '2', 'en', 'off', 'latency', '0', 'precision', 'Full', ...
	    'ShowName', 'off', 'align_bp', 'on', 'Position', [-290   -66  -260   -39]);

    reuse_block(blk, 'Logical1', 'xbsIndex_r4/Logical', 'logical_function', 'AND', ...
	    'inputs', '2', 'en', 'off', 'latency', '0', 'precision', 'Full', ...
	    'ShowName', 'off', 'align_bp', 'on', 'Position', [260    54   290    81]);

    reuse_block(blk, 'Logical2', 'xbsIndex_r4/Logical', 'logical_function', 'AND', ...
	    'inputs', '2', 'en', 'off', 'latency', '0', 'precision', 'Full', ...
	    'ShowName', 'off', 'align_bp', 'on', 'Position', [260   164   290   191]);

        % Edge detect
    reuse_block(blk, 'edge_detect', 'casper_library_misc/edge_detect','edge', 'Rising', ...
 		 'polarity','Active High', 'Position', [-215    97  -190   113]);

    reuse_block(blk, 'edge_detect1', 'casper_library_misc/edge_detect','edge', 'Rising', ...
 		 'polarity','Active High', 'Position', [-215    22  -190    38]);

    reuse_block(blk, 'edge_detect2', 'casper_library_misc/edge_detect','edge', 'Rising', ...
 		 'polarity','Active High', 'Position', [-215   -58  -190   -42]);

        % Counters
    reuse_block(blk, 'Counter', 'xbsIndex_r4/Counter', 'cnt_type', 'Count Limited', ...
        'operation','Up','start_count', '0', 'cnt_by_val', '1', ...
        'cnt_to', '1','arith_type', 'Unsigned','n_bits', '1', ...
        'bin_pt', '0','rst','on', 'en', 'on', 'explicit_period','on','period', '1', ...
        'ShowName', 'off', 'implementation','Fabric','Position', [-135    -1   -95    41]);

    reuse_block(blk, 'Counter1', 'xbsIndex_r4/Counter', 'cnt_type', 'Count Limited', ...
        'operation','Up','start_count', '0', 'cnt_by_val', '1', ...
        'cnt_to', '1','arith_type', 'Unsigned','n_bits', '1', ...
        'bin_pt', '0','rst','off', 'en', 'on', 'explicit_period','on','period', '1', ...
        'ShowName', 'off', 'implementation','Fabric','Position', [-140    93   -95   117]);

        % Delay
    reuse_block(blk, 'Delay', 'xbsIndex_r4/Delay','rst', 'off', ...
 		 'ShowName', 'off', 'latency','1', 'Position', [-125   133  -110   147]);

	    % Slice
    reuse_block(blk, 'Slice0', 'xbsIndex_r4/Slice', 'boolean_output', 'on', ...
	    'ShowName', 'off', 'mode', 'Lower Bit Location + Width', 'bit1', '0', ...
	    'base1', 'LSB of Input', 'Position', [-35    97   -10   113]);

    reuse_block(blk, 'Slice1', 'xbsIndex_r4/Slice', 'boolean_output', 'on', ...
	    'ShowName', 'off', 'mode', 'Lower Bit Location + Width', 'bit1', '0', ...
	    'base1', 'LSB of Input', 'Position', [-35   132   -10   148]);

    reuse_block(blk, 'Slice2', 'xbsIndex_r4/Slice', 'boolean_output', 'on', ...
	    'ShowName', 'off', 'mode', 'Lower Bit Location + Width', 'bit1', '0', ...
	    'base1', 'LSB of Input', 'Position', [-430   -18  -405    -2]);

        % Mux
    reuse_block(blk, 'Mux', 'xbsIndex_r4/Mux', 'inputs', '2', 'latency', '0', ...
	    'ShowName', 'off', 'precision', 'Full', 'Position', [35    53    80   157]);

        % Terminator
    reuse_block(blk, 'term', 'built-in/Terminator', 'ShowName', 'off', ...
        'Position', [460   248   475   262]);

	    % output ports
    reuse_block(blk, 'we0', 'built-in/outport', 'Port', '1', ...
        'Position', [450    63   480    77]);

    reuse_block(blk, 'we1', 'built-in/outport', 'Port', '2', ...
        'Position', [450   173   480   187]);

    %add lines between blocks

        % add lines in the valid path

    add_line(blk,'valid/1', 'goto_v0/1',        'autorouting', 'on');
    add_line(blk,'valid/1', 'edge_detect/1',    'autorouting', 'on');

	    % add lines in the constants outputs

    add_line(blk,'Constant/1', 'reading/1',     'autorouting', 'on');

	    % add lines in the software register outputs

    add_line(blk,'reading/1', 'Slice2/1',         'autorouting', 'on');
    add_line(blk,'mem_select/1','term/1', 	    'autorouting', 'on');

        % add lines in the from outputs

    add_line(blk, 'from_w0/1', 'Delay/1',       'autorouting', 'on');
    add_line(blk, 'from_v0/1', 'Not0/1',        'autorouting', 'on');
    add_line(blk, 'from_v1/1', 'Logical1/1',    'autorouting', 'on');
    add_line(blk, 'from_v2/1', 'Logical2/1',    'autorouting', 'on');

        % add lines in the inverter outputs

    add_line(blk,'Not0/1', 'Logical0/1',        'autorouting', 'on');
    add_line(blk,'Not1/1', 'Logical0/2',        'autorouting', 'on');
    add_line(blk,'Not2/1', 'Logical2/2',        'autorouting', 'on');
    add_line(blk,'Not2/1', 'mem_select/1',      'autorouting', 'on');

        % add lines in Logical outputs

    add_line(blk, 'Logical0/1', 'edge_detect2/1',   'autorouting', 'on');
    add_line(blk, 'Logical1/1', 'we0/1',            'autorouting', 'on');
    add_line(blk, 'Logical2/1', 'we1/1',            'autorouting', 'on');

        % add lines in Edge detect ouputs

    add_line(blk, 'edge_detect2/1', 'Counter/1', 'autorouting', 'on');
    add_line(blk, 'edge_detect1/1', 'Counter/2', 'autorouting', 'on');
    add_line(blk, 'edge_detect/1', 'Counter1/1', 'autorouting', 'on');

        % add lines in Counters outputs

    add_line(blk, 'Counter/1', 'Mux/1',         'autorouting', 'on');
    add_line(blk, 'Counter1/1', 'Slice0/1',     'autorouting', 'on');

        % add lines in Delay's outputs

    add_line(blk, 'Delay/1', 'Slice1/1',        'autorouting', 'on');

        % add lines in Slice's outputs

    add_line(blk, 'Slice0/1', 'Mux/2',          'autorouting', 'on');
    add_line(blk, 'Slice1/1', 'Mux/3',          'autorouting', 'on');
    add_line(blk, 'Slice2/1', 'Not1/1',         'autorouting', 'on');
    add_line(blk, 'Slice2/1', 'edge_detect1/1', 'autorouting', 'on');

        % add lines in Mux outputs

    add_line(blk, 'Mux/1', 'goto_w0/1',         'autorouting', 'on');
    add_line(blk, 'Mux/1', 'Not2/1',            'autorouting', 'on');
    add_line(blk, 'Mux/1', 'Logical1/2',        'autorouting', 'on');
                                                                                                
else  

	    % inputs ports
    reuse_block(blk, 'valid', 'built-in/inport', 'Port', '1', ...
        'Position', [145   443   175   457]);

        % Go to
    reuse_block(blk, 'goto_r0', 'built-in/goto','GotoTag', 'reset', ...
        'ShowName', 'off', 'Position', [465    32   530    48])

    reuse_block(blk, 'goto_sel', 'built-in/goto','GotoTag', 'sel', ...
        'ShowName', 'off', 'Position', [1355         339        1395         351])

        % From
    reuse_block(blk, 'from_r0', 'built-in/from','GotoTag', 'reset', ...
        'ShowName', 'off', 'Position', [935         264        1000         276])

    reuse_block(blk, 'from_r1', 'built-in/from','GotoTag', 'reset', ...
        'ShowName', 'off', 'Position', [935         374        1000         386])

    reuse_block(blk, 'from_sel', 'built-in/from','GotoTag', 'sel', ...
        'ShowName', 'off', 'Position', [325   168   360   182])

	    % edge_detect
    reuse_block(blk, 'edge_detect', 'casper_library_misc/edge_detect','edge', 'Rising', ...
 		 'polarity','Active High', 'Position', [465   402   490   418]);

    reuse_block(blk, 'edge_detect1', 'casper_library_misc/edge_detect','edge', 'Rising', ...
 		 'polarity','Active High', 'Position', [935   402   960   418]);

    reuse_block(blk, 'edge_detect2', 'casper_library_misc/edge_detect','edge', 'Falling', ...
 		 'polarity','Active High', 'Position', [935   292   960   308]);

    reuse_block(blk, 'edge_detect3', 'casper_library_misc/edge_detect','edge', 'Rising', ...
 		 'polarity','Active High', 'Position', [400    32   425    48]);

	    % Counter
    reuse_block(blk, 'Counter', 'xbsIndex_r4/Counter', 'cnt_type', 'Count Limited', ...
        'operation','Down','start_count', '1', 'cnt_by_val', '1', ...
        'ShowName', 'off', 'cnt_to', '0','arith_type', 'Unsigned','n_bits', '1', ...
        'bin_pt', '0','rst','on', 'en', 'on', 'explicit_period','on','period', '1', ...
        'implementation','Fabric','Position', [1020         257        1085         313]);

    reuse_block(blk, 'Counter1', 'xbsIndex_r4/Counter', 'cnt_type', 'Count Limited', ...
        'operation','Down','start_count', '1', 'cnt_by_val', '1', ...
        'ShowName', 'off', 'cnt_to', '0','arith_type', 'Unsigned','n_bits', '1', ...
        'bin_pt', '0','rst','on', 'en', 'on','explicit_period','on','period', '1', ...
        'implementation','Fabric','Position', [1020         367        1085         423]);

	    % Constant
    reuse_block(blk, 'Constant1', 'xbsIndex_r4/Constant', 'const', '0', ...
        'arith_type', 'Boolean','explicit_period', 'on', 'period', '1', ...
	    'ShowName', 'off', 'Position', [615   152   670   178]);

    reuse_block(blk, 'Constant2', 'xbsIndex_r4/Constant','const', '1', ...
        'arith_type', 'Boolean','explicit_period', 'on', 'period', '1', ...
	    'ShowName', 'off', 'Position', [305   397   360   423]);

    reuse_block(blk, 'Constant3', 'built-in/Constant', 'Value', '0', ...
	    'SampleTime', 'inf', 'OutDataTypeStr','Inherit: Inherit from ''Constant value''', ...
	    'ShowName', 'off', 'Position', [145   193   180   207]);

    reuse_block(blk, 'Constant4', 'xbsIndex_r4/Constant','const', '0', ...
        'arith_type', 'Boolean','explicit_period', 'on', 'period', '1', ...
	    'ShowName', 'off', 'Position', [295   212   350   238]);

    reuse_block(blk, 'Constant5', 'built-in/Constant', 'Value', '0', ...
	    'SampleTime', 'inf', 'OutDataTypeStr','Inherit: Inherit from ''Constant value''', ...
	    'ShowName', 'off', 'Position', [640   403   675   417]);

	    % Slice
    reuse_block(blk, 'Slice1', 'xbsIndex_r4/Slice', 'boolean_output', 'on', ...
	    'ShowName', 'off', 'mode', 'Lower Bit Location + Width', 'bit1', '0', ...
	    'base1', 'LSB of Input', 'Position', [865   402   890   418]);

    reuse_block(blk, 'Slice2', 'xbsIndex_r4/Slice', 'boolean_output', 'on', ...
	    'ShowName', 'off', 'mode', 'Lower Bit Location + Width', 'bit1', '0', ...
	    'base1', 'LSB of Input', 'Position', [325   192   350   208]);

    reuse_block(blk, 'Slice3', 'xbsIndex_r4/Slice', 'boolean_output', 'on', ...
	    'ShowName', 'off', 'mode', 'Lower Bit Location + Width', 'bit1', '0', ...
	    'base1', 'LSB of Input', 'Position', [1140         387        1165         403]);

    reuse_block(blk, 'Slice4', 'xbsIndex_r4/Slice', 'boolean_output', 'on', ...
	    'ShowName', 'off', 'mode', 'Lower Bit Location + Width', 'bit1', '0', ...
	    'base1', 'LSB of Input', 'Position', [1140         277        1165         293]);

	    % Mux
    reuse_block(blk, 'Mux', 'xbsIndex_r4/Mux', 'inputs', '2', 'latency', '0', ...
	    'ShowName', 'off', 'precision', 'Full', 'Position', [695   113   740   217]);

    reuse_block(blk, 'Mux1', 'xbsIndex_r4/Mux', 'inputs', '2', 'latency', '0', ...
	    'ShowName', 'off', 'precision', 'Full', 'Position', [400   374   435   446]);

    reuse_block(blk, 'Mux2', 'xbsIndex_r4/Mux', 'inputs', '2', 'latency', '0', ...
	    'ShowName', 'off', 'precision', 'Full', 'Position', [400   164   435   236]);

	    % software register
    reuse_block(blk, 'sel_we', 'xps_library/software register', ...
	    'io_dir', 'From Processor', 'Position', [210   182   285   218]);

    reuse_block(blk, 'lec_done', 'xps_library/software register', ...
	    'io_dir', 'From Processor', 'Position', [720   390   805   430]);

    reuse_block(blk, 'rtr', 'xps_library/software register', 'numios', '1', ...
	    'io_delay', '0', 'bitwidth1', '32', 'arith_type1', 'Unsigned', ...
        'io_dir','To Processor', 'bin_pt1', '0', 'Position', ...
        [1225         192        1330         228]);

        % Converter

    reuse_block(blk, 'Convert', 'xbsIndex_r4/Convert', ...
	    'gui_display_data_type', 'Fixed-point', 'arith_type', 'Unsigned', 'n_bits', '32', ...
        'bin_pt', '0', 'quantization', 'Truncate', 'overflow', 'Wrap', 'en', 'off', ...
        'ShowName', 'off', 'latency', '0', 'Position', [1135         187        1165         233]);

	    % Logical
    reuse_block(blk, 'Logical', 'xbsIndex_r4/Logical', 'logical_function', 'AND', ...
	    'inputs', '2', 'en', 'off', 'latency', '0', 'precision', 'Full', ...
	    'ShowName', 'off', 'align_bp', 'on', 'Position', [570    99   610   161]);

    reuse_block(blk, 'Logical2', 'xbsIndex_r4/Logical', 'logical_function', 'AND', ...
	    'inputs', '2', 'en', 'off', 'latency', '0', 'precision', 'Full', ...
	    'ShowName', 'off', 'align_bp', 'on', 'Position', [1260         314        1300         376]);

	    % Inverter
    reuse_block(blk, 'Inverter', 'xbsIndex_r4/Inverter', 'en', 'off', ...
	    'ShowName', 'off', 'latency', '0', 'Position', [1195         267        1225         303]);

        % Terminator
    reuse_block(blk, 'term', 'built-in/Terminator', 'ShowName', 'off', ...
        'Position', [1370         203        1385         217]);

	    % output ports
    reuse_block(blk, 'we', 'built-in/outport', 'Port', '1', ...
        'Position', [930   158   960   172]);


    %add lines between blocks

        
        % add lines in the valid path

    add_line(blk,'valid/1','Mux1/3');

	    % add lines in the Edge detect paths
                                                
    add_line(blk,'edge_detect1/1','Counter1/2', 'autorouting', 'on');
    add_line(blk,'edge_detect2/1','Counter/2',  'autorouting', 'on');
    add_line(blk,'edge_detect3/1','goto_r0/1',  'autorouting', 'on');

        % add lines in the From outputs

    add_line(blk,'from_r0/1','Counter/1',       'autorouting', 'on');
    add_line(blk,'from_r1/1','Counter1/1',      'autorouting', 'on');
    add_line(blk,'from_sel/1','Mux2/1', 		'autorouting', 'on');

	    % add lines in the Counter outputs

    add_line(blk,'Counter/1','Slice4/1', 		'autorouting', 'on');
    add_line(blk,'Counter/1','Convert/1', 		'autorouting', 'on');
    add_line(blk,'Counter1/1','Slice3/1', 		'autorouting', 'on');

        % add lines in the Converter output

    add_line(blk,'Convert/1','rtr/1', 		    'autorouting', 'on');

	    % add lines in the Constants outputs

    add_line(blk,'Constant1/1','Mux/2', 		'autorouting', 'on');
    add_line(blk,'Constant2/1','Mux1/2', 		'autorouting', 'on');
    add_line(blk,'Constant3/1','sel_we/1', 		'autorouting', 'on');
    add_line(blk,'Constant4/1','Mux2/3', 		'autorouting', 'on');
    add_line(blk,'Constant5/1','lec_done/1', 	'autorouting', 'on');

	     % add lines in the Slice outputs

    add_line(blk,'Slice1/1','edge_detect1/1', 	'autorouting', 'on');
    add_line(blk,'Slice2/1','Mux1/1', 			'autorouting', 'on');
    add_line(blk,'Slice2/1','Mux2/2', 			'autorouting', 'on');
    add_line(blk,'Slice2/1','edge_detect3/1', 	'autorouting', 'on');
    add_line(blk,'Slice3/1','Logical2/2', 		'autorouting', 'on');
    add_line(blk,'Slice4/1','Inverter/1', 		'autorouting', 'on');

	    % add lines in the Mux outputs

    add_line(blk,'Mux/1','edge_detect2/1', 		'autorouting', 'on');
    add_line(blk,'Mux1/1','edge_detect/1', 		'autorouting', 'on');

	    % add lines in the Software register outputs

    add_line(blk,'sel_we/1','Slice2/1', 		'autorouting', 'on');
    add_line(blk,'lec_done/1','Slice1/1', 		'autorouting', 'on');
    add_line(blk,'rtr/1','term/1', 	        	'autorouting', 'on');

	    % add lines in the Logical outputs

    add_line(blk,'Logical/1','Mux/1', 			'autorouting', 'on');
    add_line(blk,'Logical2/1','goto_sel/1',		'autorouting', 'on');

	    % add lines in the Inverter outputs

    add_line(blk,'Inverter/1','Logical2/1', 	'autorouting', 'on');



    if (accum == 2) 

    % Logical

	    reuse_block(blk, 'Logical1', 'xbsIndex_r4/Logical', 'logical_function', 'AND', ...
		    'inputs', '2', 'en', 'off', 'latency', '0', 'precision', 'Full', ...
		    'ShowName', 'off', 'align_bp', 'on', 'Position', [490    84   530   146]);

    % pulse_exit
	    reuse_block(blk, 'pulse_ext', 'casper_library_misc/pulse_ext', ...
		    'pulse_len', num2str(fft_size/fft_outputs), 'Position', [510   401   545   419]);

		    % add lines in the edge_detect paths

	    add_line(blk,'edge_detect/1','pulse_ext/1', 'autorouting', 'on');

		    % add lines in the Logical outputs

	    add_line(blk,'Logical1/1','Logical/1', 		'autorouting', 'on');

		    % add lines in the pulse_ext output

	    add_line(blk,'pulse_ext/1','Logical/2', 	'autorouting', 'on');

		    % add lines in the mux outputs

	    add_line(blk,'Mux/1','we/1',                'autorouting', 'on');
	    add_line(blk,'Mux2/1','Logical1/2', 		'autorouting', 'on');

        	% add lines in the valid path

	    add_line(blk,'valid/1','Logical1/1', 		'autorouting', 'on');
	    add_line(blk,'valid/1','Mux/3', 			'autorouting', 'on');

    elseif (accum == 3)

    % pulse_exit
	    reuse_block(blk, 'pulse_ext1', 'casper_library_misc/pulse_ext', 'ShowName', 'off', ...
		    'pulse_len', num2str(fft_size/fft_outputs), 'Position', [855   156   890   174]);

		    % add lines in the edge_detect paths

	    add_line(blk,'edge_detect/1','Logical/2', 	'autorouting', 'on');
	    add_line(blk,'edge_detect/1','Mux/3', 		'autorouting', 'on');

		    % add lines in the pulse_ext output

	    add_line(blk,'pulse_ext1/1','we/1', 		'autorouting', 'on');

		    % add lines in the mux outputs

	    add_line(blk,'Mux/1','pulse_ext1/1', 		'autorouting', 'on');
	    add_line(blk,'Mux2/1','Logical/1', 			'autorouting', 'on');
		
    end

end
      
clean_blocks(blk);

%set_param(blk,'AttributesFormatString',[num2str(num1),',',num2str(num2)]);


save_state(blk, 'defaults', defaults, varargin{:});
end
