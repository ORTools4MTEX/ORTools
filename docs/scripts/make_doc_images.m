function make_doc_images(outDir)
    %% Function description:
    % This function generates the plot images and text snippets used by the
    % documentation. It runs the ORTools functions on MTEX example datasets
    % (and on the TRWIP steel dataset in data/input/ebsd) without any user
    % interaction and saves one PNG per function to docs/images.
    %
    % The screenshots of GUIs (computeGrains, guiOR, grainClick and
    % recolorPhases) cannot be generated and are kept in the repository.
    %
    %% Syntax:
    %  make_doc_images
    %  make_doc_images(outDir)
    %
    %% Input:
    %  outDir   - folder the images are written to (default: docs/images)
    %
    %% Requirements:
    %  MTEX on the MATLAB path (run startup_mtex first), plus the Signal
    %  Processing, Image Processing and Statistics toolboxes

    root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
    if nargin < 1
        outDir = fullfile(root, 'docs', 'images');
    end
    snippetDir = fullfile(root, 'docs', 'snippets');

    % Put ORTools on the path
    addpath(root);
    currentFolder;

    ensureFolder(fullfile(outDir, 'x'));
    ensureFolder(fullfile(snippetDir, 'x'));

    set(groot, 'DefaultFigureVisible', 'off');
    set(groot, 'DefaultFigureWindowStyle', 'normal');
    setMTEXpref('xAxisDirection', 'east');
    setMTEXpref('zAxisDirection', 'outOfPlane');
    setMTEXpref('FontSize', 14);
    setInterp2Tex;

    failed = {};

    %% Lath martensite (MTEX dataset 'martensite')
    screenPrint('SegmentStart', 'Lath martensite');
    ebsd = mtexdata('martensite');
    [grains, ebsd] = calcGrains(ebsd('indexed'), 'angle', 3 * degree);
    ebsd(grains(grains.numPixel < 3)) = [];
    [grains, ebsd] = calcGrains(ebsd('indexed'), 'angle', 3 * degree);
    grains = smoothBoundary(grains, 5);
    ebsd = renameByMineral(ebsd, {'fcc', 'Gamma'; 'bcc', 'AlphaP'});
    job = defineJob(ebsd, grains, 'Gamma', 'AlphaP');

    KS = orientation.KurdjumovSachs(job.csParent, job.csChild);
    NW = orientation.NishiyamaWassermann(job.csParent, job.csChild);
    job.p2c = KS;
    job.calcParent2Child('local');

    failed = snap(failed, outDir, 'plotHist_OR_misfit', ...
                  @() plotHist_OR_misfit(job, [KS, NW], 'legend', {'K-S OR', 'N-W OR'}));
    failed = saveText(failed, snippetDir, 'ORinfo', @() ORinfo(job.p2c));
    failed = snap(failed, outDir, 'plotMap_IPF_p2c', ...
                  @() plotMap_IPF_p2c(job, vector3d.Z, 'linewidth', 2));
    failed = snap(failed, outDir, 'plotMap_gB_c2c', ...
                  @() plotMap_gB_c2c(job, 'linewidth', 2));
    failed = snap(failed, outDir, 'plotMap_gB_misfit', ...
                  @() plotMap_gB_misfit(job, 'linewidth', 2, 'maxColor', 5));
    failed = snap(failed, outDir, 'plotMap_gB_prob', ...
                  @() plotMap_gB_prob(job, 'threshold', 2.5 * degree, 'tolerance', 2.5 * degree, 'linewidth', 2));

    % Clusters of the grain graph (as in Example 1), on a separate job
    jobGraph = defineJob(ebsd, grains, 'Gamma', 'AlphaP');
    jobGraph.p2c = job.p2c;
    jobGraph.calcGraph('threshold', 2.5 * degree, 'tolerance', 2.5 * degree);
    jobGraph.clusterGraph('inflationPower', 1.6);
    failed = snap(failed, outDir, 'plotMap_clusters', ...
                  @() plotMap_clusters(jobGraph, 'linewidth', 2));

    % Reconstruction with the variant graph approach (as in Example 7)
    job.calcVariantGraph('threshold', 4 * degree, 'tolerance', 3.5 * degree);
    job.clusterVariantGraph;
    job.calcParentFromVote('minProb', 0.5);
    job.calcGBVotes('p2c', 'reconsiderAll');
    job.calcParentFromVote;
    job.mergeSimilar('threshold', 7.5 * degree);
    job.mergeInclusions('maxSize', 150);
    job.calcVariants;

    [~, maxGrainId] = max(job.grains.area);
    [~, maxParentIdx] = max(job.parentGrains.area);
    maxParentId = job.parentGrains.id(maxParentIdx);

    failed = snap(failed, outDir, 'plotPDF_variants', @() plotPDF_variants(job));
    failed = snap(failed, outDir, 'plotPDF_packets', @() plotPDF_packets(job));
    failed = snap(failed, outDir, 'plotPDF_bain', @() plotPDF_bain(job));
    failed = snap(failed, outDir, 'plotMap_variants', ...
                  @() plotMap_variants(job, 'linewidth', 1));
    failed = snap(failed, outDir, 'plotMap_packets', ...
                  @() plotMap_packets(job, 'linewidth', 3));
    failed = snap(failed, outDir, 'plotMap_bain', ...
                  @() plotMap_bain(job, 'linewidth', 2, 'colormap', magma));
    failed = snap(failed, outDir, 'plotMap_KSvariantPairs', ...
                  @() plotMap_KSvariantPairs(job, 'parentGrainId', maxGrainId, 'linewidth', 2));
    failed = snap(failed, outDir, 'plotMap_blockWidths', ...
                  @() plotMap_blockWidths(job, 'parentGrainId', maxGrainId, 'linewidth', 1.5));
    failed = snap(failed, outDir, 'plotStack', ...
                  @() plotStack(job, 'parentGrainId', maxGrainId, 'linewidth', 1.5));
    failed = snap(failed, outDir, 'computehabitPlane', ...
                  @() computeHabitPlane(job, 'Radon', 'minClusterSize', 50, 'plotTraces'));
    failed = snap(failed, outDir, 'computeParentTwins', ...
                  @() computeParentTwins(job, maxParentId));

    %% Alpha-beta titanium (MTEX dataset 'alphaBetaTitanium')
    screenPrint('SegmentStart', 'Alpha-beta titanium');
    ebsd = mtexdata('alphaBetaTitanium');
    [grains, ebsd] = calcGrains(ebsd('indexed'), 'threshold', 1.5 * degree, ...
                                'removeQuadruplePoints');
    ebsd = renameByMineral(ebsd, {'alpha', 'Alpha'; 'beta', 'Beta'});
    job = defineJob(ebsd, grains, 'Beta', 'Alpha');
    job.p2c = orientation.Burgers(job.csParent, job.csChild);

    failed = snap(failed, outDir, 'plotIPDF_gB_misfit', @() plotIPDF_gB_misfit(job));
    failed = snap(failed, outDir, 'plotIPDF_gB_prob', @() plotIPDF_gB_prob(job));
    % Fit the parent-child misorientation peak around the Burgers OR
    misoRange.min = angle(job.p2c) / degree - 2.5;
    misoRange.max = angle(job.p2c) / degree + 2.5;
    failed = snap(failed, outDir, 'peakFitORs', @() peakFitORs(job, misoRange));

    % Reconstruction (as in Example 4) for the texture transformation
    job.calcTPVotes('minFit', 2.5 * degree, 'maxFit', 5 * degree);
    job.calcParentFromVote('minProb', 0.7);
    for k = 1:3
        job.calcGBVotes('p2c', 'threshold', k * 2.5 * degree);
        job.calcParentFromVote;
    end
    job.mergeSimilar('threshold', 5 * degree);
    job.mergeInclusions('maxSize', 5);
    job.calcVariants;
    hParent = [Miller(1, 1, 0, job.csParent), Miller(2, 0, 0, job.csParent)];
    hChild = [Miller(0, 0, 0, 2, job.csChild), Miller(1, 1, -2, 0, job.csChild)];
    inputODF = calcDensity(job.parentEBSD.orientations); %#ok<NASGU>
    pfNameIn = fullfile(tempdir, 'ORTools_inputTexture.mat');
    pfNameOut = fullfile(tempdir, 'ORTools_outputTexture.mat');
    save(pfNameIn, 'inputODF');
    failed = snap(failed, outDir, 'plotPODF_transformation', ...
                  @() plotPODF_transform(job, hParent, hChild, 'import', pfNameIn, 'export', pfNameOut));

    %% TRWIP steel (data/input/ebsd/TRWIPsteel.ctf)
    screenPrint('SegmentStart', 'TRWIP steel');
    ebsd = loadEBSD_ctf(fullfile(root, 'data', 'input', 'ebsd', 'TRWIPsteel.ctf'), ...
                        'convertSpatial2EulerReferenceFrame');
    ebsd = ebsd('indexed');
    [grains, ebsd] = calcGrains(ebsd('indexed'), 'threshold', 3 * degree, ...
                                'removeQuadruplePoints');
    ebsd = renameByMineral(ebsd, {'fcc', 'Gamma'; 'bcc', 'AlphaP'; 'epsilon', 'Epsilon'});
    job = defineJob(ebsd, grains, 'Gamma', 'AlphaP');

    failed = snap(failed, outDir, 'plotMap_phases', @() plotMap_phases(job, 'linewidth', 2));
    failed = snap(failed, outDir, 'plotMap_gB_p2c', @() plotMap_gB_p2c(job, 'linewidth', 1.5));

    %% Report
    if isempty(failed)
        screenPrint('SegmentStart', 'All documentation images were generated');
    else
        error('make_doc_images:failed', 'Failed to generate:\n  %s', strjoin(failed, '\n  '));
    end
end

function failed = snap(failed, outDir, name, plotFun)
    %% Run a plotting function and save the figure(s) it opens as PNG
    % The first figure is saved as <name>.png, any further ones as
    % <name>_2.png, <name>_3.png, ...
    close all;
    try
        plotFun();
        drawnow;
        figs = findall(groot, 'Type', 'figure');
        if isempty(figs)
            error('no figure was created');
        end
        [~, order] = sort(arrayfun(@figureOrder, figs));
        figs = figs(order);
        for ii = 1:numel(figs)
            fileName = name;
            if ii > 1
                fileName = sprintf('%s_%d', name, ii);
            end
            exportgraphics(figs(ii), fullfile(outDir, [fileName, '.png']), 'Resolution', 150);
        end
        screenPrint('Step', sprintf('Saved %s (%d figure(s))', name, numel(figs)));
    catch err
        failed{end + 1} = sprintf('%s: %s', name, err.message);
        screenPrint('Step', sprintf('FAILED %s: %s', name, err.message));
    end
    close all;
end

function n = figureOrder(fig)
    %% Figure number for sorting (figures without a number go last)
    n = fig.Number;
    if isempty(n)
        n = Inf;
    end
end

function failed = saveText(failed, snippetDir, name, printFun)
    %% Capture the command window output of a function as a text snippet
    try
        txt = evalc('printFun()');
        fid = fopen(fullfile(snippetDir, [name, '.txt']), 'w', 'n', 'UTF-8');
        fprintf(fid, '%s', strtrim(txt));
        fclose(fid);
        screenPrint('Step', sprintf('Saved %s.txt', name));
    catch err
        failed{end + 1} = sprintf('%s: %s', name, err.message);
        screenPrint('Step', sprintf('FAILED %s: %s', name, err.message));
    end
end

function ebsd = renameByMineral(ebsd, renames)
    %% Rename phases whose mineral name contains a given pattern
    % renames - {pattern, newName; ...}, matched case-insensitively
    % (the same renaming as renamePhases, without the selection dialog)
    for ii = 2:numel(ebsd.CSList)
        for jj = 1:size(renames, 1)
            if contains(lower(ebsd.CSList{ii}.mineral), lower(renames{jj, 1}))
                ebsd.CSList{ii}.mineral = renames{jj, 2};
                break
            end
        end
    end
end

function job = defineJob(ebsd, grains, parentName, childName)
    %% Define a parentGrainReconstructor job for named phases
    % (the same as setParentGrainReconstructor, without the selection dialog)
    csParent = findPhase(ebsd, parentName);
    csChild = findPhase(ebsd, childName);
    p2c0 = orientation.byEuler(0, 0, 0, csParent, csChild);
    job = parentGrainReconstructor(ebsd, grains, p2c0);
end

function cs = findPhase(ebsd, name)
    %% Crystal symmetry of the phase with the given mineral name
    for ii = 2:numel(ebsd.CSList)
        if strcmp(ebsd.CSList{ii}.mineral, name)
            cs = ebsd.CSList{ii};
            return
        end
    end
    error('make_doc_images:phase', 'Phase ''%s'' not found', name);
end
