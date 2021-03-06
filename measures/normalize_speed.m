function [normalized_speed, actual_speed] = normalize_speed(speed, failures, tracker, sequence)

if ~isfield(tracker, 'performance')
    error('Tracker %s has no performance profile, unable to normalize speed.', tracker.identifier);
end;

performance = tracker.performance;

factor = performance.nonlinear_native;
startup = 0;
skipping = get_global_variable('skipping', 1) - 1;

if strcmpi(tracker.interpreter, 'matlab')
    if isfield(performance, 'matlab_startup')
        startup = performance.matlab_startup;
    else
        model = get_global_variable('matlab_startup_model', []);
		if ~isempty(model)
			startup = model(1) * performance.reading + model(2);
		end;
    end;
end

failure_count = cellfun(@(x) numel(x), failures, 'UniformOutput', true);

if tracker.trax
	actual_length = sequence.length - skipping * failure_count;
	full_length = sequence.length;
	startup_time = startup * (1 + failure_count);
else
	full_length = cellfun(@(x) sum(sequence.length - x - skipping), failures, 'UniformOutput', true) + sequence.length;
	actual_length = full_length;
	startup_time = startup * (1 + failure_count);
end;

actual_speed = (((speed .* full_length) - startup_time) ./ actual_length);
normalized_speed = actual_speed / factor;
