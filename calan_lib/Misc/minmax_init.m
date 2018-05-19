function minmax_init (blk, varargin)
% Usage: minmax_init (gcb, 'var')
% Outputs the minimum or maximum of two numbers
%
% Valid 'var' names are:
% min_or_max = flag: 1: get minimum, 2: get maximum
% latency = latency of block (implemented on comparator)

    if same_state(blk, varargin{:}), return, end
    munge_block(blk, varargin{:});

    min_or_max = get_var('min_or_max', varargin{:});
    latency    = get_var('latency', varargin{:});

    reuse_block(blk, 'Relational', 'xbsIndex_r4/Relational', ...
        'latency', num2str(latency));
    if strcmp(min_or_max, 'min')
        reuse_block(blk, 'Relational', 'xbsIndex_r4/Relational', ...
        'mode', 'a>b');
    else % if min_or_max = 'max'
        reuse_block(blk, 'Relational', 'xbsIndex_r4/Relational', ...
        'mode', 'a<b');
    end
    %
    reuse_block(blk, 'delay_a', 'xbsIndex_r4/Delay', ...
        'latency', num2str(latency));
    %
    reuse_block(blk, 'delay_b', 'xbsIndex_r4/Delay', ...
        'latency', num2str(latency));
    %

    clean_blocks(blk)

    save_state(blk, varargin{:})
