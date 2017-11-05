function quant_init(blk, varargin)
%este bloque sirve para ...
defaults = {'sync', 'on', ...
            'n_inputs', 1, ...
			'arith_type', 'Signed (2''s comp)', ...
    	    'n_bits', 64, ...
            'bin_pt', 18, ...
            'overflow', 'Wrap'};
%            'data_type', 'Boolean', ...
%            'quantization', 'Round  (unbiased: Even Values)', ...

check_mask_type(blk, 'quant');

if same_state(blk, 'defaults', defaults, varargin{:}), return, end
clog('quant_init post same_state', 'trace');
munge_block(blk, varargin{:});

sync               = get_var('sync', 'defaults', defaults, varargin{:});
n_inputs           = get_var('n_inputs', 'defaults', defaults, varargin{:});
%data_type          = get_var('data_type', 'defaults', defaults, varargin{:});
arith_type         = get_var('arith_type', 'defaults', defaults, varargin{:});
n_bits             = get_var('n_bits', 'defaults', defaults, varargin{:});
bin_pt             = get_var('bin_pt', 'defaults', defaults, varargin{:});
%quantization       = get_var('quantization', 'defaults', defaults, varargin{:});
overflow           = get_var('overflow', 'defaults', defaults, varargin{:});

delete_lines(blk);

if n_bits  == 0,
    clean_blocks(blk);
    save_state(blk, 'defaults', defaults, varargin{:});  
    return; 
end

s=0;
if sync == 1
    s=1;
    % Input
    reuse_block(blk, 'sync', 'built-in/inport', 'Port', '1', ...
        'Position', [160    23   190    37]);

    % Delay
    reuse_block(blk, 'Delay_s0', 'xbsIndex_r4/Delay','rst', 'off', ...
 		 'ShowName', 'off', 'latency','1', 'Position', [275    16   300    44]);

    reuse_block(blk, 'Delay_s1', 'xbsIndex_r4/Delay','rst', 'off', ...
 		 'ShowName', 'off', 'latency','1', 'Position', [345    16   370    44]);

    reuse_block(blk, 'Delay_s2', 'xbsIndex_r4/Delay','rst', 'off', ...
 		 'ShowName', 'off', 'latency','8', 'Position', [425    16   450    44]);

    reuse_block(blk, 'Delay_s3', 'xbsIndex_r4/Delay','rst', 'off', ...
 		 'ShowName', 'off', 'latency','4', 'Position', [475    16   500    44]);

    % Output
    reuse_block(blk, 'sync_out', 'built-in/outport', 'Port', '1', ...
        'Position', [555    23   585    37]);

    % add lines
    add_line(blk,'sync/1',     'Delay_s0/1',     'autorouting', 'on');
    add_line(blk,'Delay_s0/1', 'Delay_s1/1',     'autorouting', 'on');
    add_line(blk,'Delay_s1/1', 'Delay_s2/1',     'autorouting', 'on');
    add_line(blk,'Delay_s2/1', 'Delay_s3/1',     'autorouting', 'on');
    add_line(blk,'Delay_s3/1', 'sync_out/1',     'autorouting', 'on');   
end

for i=1:n_inputs

    % Inputs
    reuse_block(blk, ['din',num2str(i-1)], 'built-in/inport', 'Port', num2str(i+s), ...
        'Position', [160    58+65*(i-1)   190    72+65*(i-1)]);

    % Delay
    reuse_block(blk, ['Delay_',num2str(i-1),'0'], 'xbsIndex_r4/Delay','rst', 'off', ...
        'ShowName', 'off', 'latency','1', 'Position', [275    51+65*(i-1)   300    79+65*(i-1)]);

    reuse_block(blk, ['Delay_',num2str(i-1),'1'], 'xbsIndex_r4/Delay','rst', 'off', ...
        'ShowName', 'off', 'latency','1', 'Position', [345    51+65*(i-1)   370    79+65*(i-1)]);

    % Round 

    reuse_block(blk, ['Round', num2str(i-1)], 'spec_lib/round', ...
        'arith_type', arith_type-1, ...
        'n_bits', num2str(n_bits), ...
        'bin_pt', num2str(bin_pt), ...
        'overflow', overflow-1, ...
        'Position', [445    56+65*(i-1)   500    94+65*(i-1)]);
    %    'quantization', quantization, ...

    % Outputs
    reuse_block(blk, ['dout', num2str(i-1)], 'built-in/outport', 'Port', num2str(i+s), ...
        'Position', [555    68+65*(i-1)   585    82+65*(i-1)]);

    %add lines between blocks

        % add lines in the In-port path

    add_line(blk,['din',num2str(i-1),'/1'], ['Delay_',num2str(i-1),'0','/1'],       'autorouting', 'on');

        % add lines in the Delay path

    add_line(blk,['Delay_',num2str(i-1),'0','/1'], ['Delay_',num2str(i-1),'1', '/1'], 'autorouting', 'on');
    add_line(blk,['Delay_',num2str(i-1),'1','/1'], ['Round', num2str(i-1),'/1'],      'autorouting', 'on');


        % add lines in the Round path

    add_line(blk,['Round', num2str(i-1),'/1'], ['dout',num2str(i-1),'/1'],           'autorouting', 'on');

end

    % Constant

%    reuse_block(blk, 'Constant', 'built-in/Constant', 'Value', '16777215', ...
%        'SampleTime', 'inf', 'OutDataTypeStr','Inherit: Inherit from ''Constant value''', ...
%        'ShowName', 'off', 'Position', [140   75+65*i   195   95+65*i]);

    % Software Register

%    reuse_block(blk, 'gain', 'xps_library/software register', ...
%        'io_dir', 'From Processor', 'Position', [225   69+65*i    325   101+65*i]);

    % Delay
%    reuse_block(blk, 'Delay_gain', 'xbsIndex_r4/Delay','rst', 'off', ...
%        'ShowName', 'off', 'latency','1', 'Position', [345   71+65*i   370   99+65*i]);

    % add lines in Constant path

%add_line(blk,'Constant/1', 'gain/1', 'autorouting', 'on');

    % add lines in Software Register path

%add_line(blk,'gain/1', 'Delay_gain/1', 'autorouting', 'on');

    % Inputs
    reuse_block(blk, 'gain', 'built-in/inport', 'Port', num2str(i+s+1), ...
        'Position', [160    58+65*i   190    72+65*i]);

for i=1:n_inputs
    add_line(blk,'gain/1', ['Round', num2str(i-1),'/2'], 'autorouting', 'on');
end

clean_blocks(blk);

save_state(blk, 'defaults', defaults, varargin{:});
end
