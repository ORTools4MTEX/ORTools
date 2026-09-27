function make_doc_images(outDir)
    %% Function description:
    % This function generates the plot images and text snippets used by the
    % documentation. It runs the ORTools functions on MTEX example datasets
    % (and on the TRWIP steel dataset in data/input/ebsd) without any user
    % interaction and saves one PNG per function to docs/images.
    %
    % The screenshots of GUIs (computeGrains, guiOR, grainClick,
    % recolorPhases and the interactive peak fitting window shown for
    % peakFitORs) cannot be generated and are kept in the repository.
    %
    %% Syntax:
    %  make_doc_images
    %  make_doc_images(outDir)
    %
    %% Input:
    %  outDir   - folder the images are written to (default: docs/images)
    %
    %% Output files:
    %  <outDir>/<name>.png          - image used by the documentation
    %  docs-review/<name>_<n>.png   - every figure a function opened, for
    %                                 choosing which ones form the image
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

    dirs.images = outDir;
    dirs.review = fullfile(root, 'docs-review');
    ensureFolder(fullfile(dirs.images, 'x'));
    ensureFolder(fullfile(dirs.review, 'x'));
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

    failed = snap(failed, dirs, 'plotHist_OR_misfit', ...
                  @() plotHist_OR_misfit(job, [KS, NW], 'legend', {'K-S OR', 'N-W OR'}));
    failed = saveText(failed, snippetDir, 'ORinfo', @() ORinfo(job.p2c));
    failed = snap(failed, dirs, 'plotMap_gB_misfit', ...
                  @() plotMap_gB_misfit(job, 'linewidth', 2, 'maxColor', 5));
    failed = snap(failed, dirs, 'plotMap_gB_prob', ...
                  @() plotMap_gB_prob(job, 'threshold', 2.5 * degree, 'tolerance', 2.5 * degree, 'linewidth', 2));

    % Clusters of the grain graph (as in Example 1), on a separate job
    jobGraph = defineJob(ebsd, grains, 'Gamma', 'AlphaP');
    jobGraph.p2c = job.p2c;
    jobGraph.calcGraph('threshold', 2.5 * degree, 'tolerance', 2.5 * degree);
    jobGraph.clusterGraph('inflationPower', 1.6);
    failed = snap(failed, dirs, 'plotMap_clusters', ...
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

    % Id (not index) of the largest reconstructed parent grain
    [~, maxParentIdx] = max(job.parentGrains.area);
    maxParentId = job.parentGrains.id(maxParentIdx);

    failed = snap(failed, dirs, 'plotPDF_variants', @() plotPDF_variants(job));
    failed = snap(failed, dirs, 'plotPDF_packets', @() plotPDF_packets(job));
    failed = snap(failed, dirs, 'plotPDF_bain', @() plotPDF_bain(job));
    failed = snap(failed, dirs, 'plotMap_variants', ...
                  @() plotMap_variants(job, 'linewidth', 1));
    failed = snap(failed, dirs, 'plotMap_packets', ...
                  @() plotMap_packets(job, 'linewidth', 3));
    failed = snap(failed, dirs, 'plotMap_bain', ...
                  @() plotMap_bain(job, 'linewidth', 2, 'colormap', magma));
    failed = snap(failed, dirs, 'plotMap_KSvariantPairs', ...
                  @() plotMap_KSvariantPairs(job, 'parentGrainId', maxParentId, 'linewidth', 2));
    failed = snap(failed, dirs, 'plotMap_blockWidths', ...
                  @() plotMap_blockWidths(job, 'parentGrainId', maxParentId, 'linewidth', 1.5));
    failed = snap(failed, dirs, 'plotStack', ...
                  @() plotStack(job, 'parentGrainId', maxParentId, 'linewidth', 1.5), 'grid5');
    failed = snap(failed, dirs, 'computehabitPlane', ...
                  @() computeHabitPlane(job, 'Shape', 'minClusterSize', 50, 'reliability', 0.5, 'plotTraces'));
    failed = snap(failed, dirs, 'computeParentTwins', ...
                  @() computeParentTwins(job, maxParentId));

    % Texture transformation of the reconstructed parent texture
    hParent = [Miller(1, 1, 1, job.csParent), Miller(2, 0, 0, job.csParent), Miller(2, 2, 0, job.csParent)];
    hChild = [Miller(1, 1, 0, job.csChild), Miller(2, 0, 0, job.csChild), Miller(2, 1, 1, job.csChild)];
    inputODF = calcDensity(job.parentEBSD.orientations); %#ok<NASGU>
    pfNameIn = fullfile(tempdir, 'ORTools_inputTexture.mat');
    pfNameOut = fullfile(tempdir, 'ORTools_outputTexture.mat');
    save(pfNameIn, 'inputODF');
    % Figures: 1 parent PFs, 2 parent ODF, 3 child PFs, 4 child ODF
    failed = snap(failed, dirs, 'plotPODF_transformation', ...
                  @() plotPODF_transform(job, hParent, hChild, 'import', pfNameIn, 'export', pfNameOut), [1 3; 2 4]);

    %% Alpha-beta titanium (MTEX dataset 'alphaBetaTitanium')
    screenPrint('SegmentStart', 'Alpha-beta titanium');
    ebsd = mtexdata('alphaBetaTitanium');
    [grains, ebsd] = calcGrains(ebsd('indexed'), 'threshold', 1.5 * degree, ...
                                'removeQuadruplePoints');
    ebsd = renameByMineral(ebsd, {'alpha', 'Alpha'; 'beta', 'Beta'});
    job = defineJob(ebsd, grains, 'Beta', 'Alpha');
    job.p2c = orientation.Burgers(job.csParent, job.csChild);

    failed = snap(failed, dirs, 'plotIPDF_gB_misfit', @() plotIPDF_gB_misfit(job, 'colormapP', jet), 1:3);
    failed = snap(failed, dirs, 'plotIPDF_gB_prob', @() plotIPDF_gB_prob(job), 1:3);

    %% TRWIP steel (data/input/ebsd/TRWIPsteel.ctf)
    screenPrint('SegmentStart', 'TRWIP steel');
    ebsd = loadEBSD_ctf(fullfile(root, 'data', 'input', 'ebsd', 'TRWIPsteel.ctf'), ...
                        'convertSpatial2EulerReferenceFrame');
    ebsd = ebsd('indexed');
    [grains, ebsd] = calcGrains(ebsd('indexed'), 'threshold', 3 * degree, ...
                                'removeQuadruplePoints');
    ebsd = renameByMineral(ebsd, {'fcc', 'Gamma'; 'bcc', 'AlphaP'; 'epsilon', 'Epsilon'});
    job = defineJob(ebsd, grains, 'Gamma', 'AlphaP');

    failed = snap(failed, dirs, 'plotMap_phases', @() plotMap_phases(job, 'linewidth', 2));
    % Epsilon martensite as parent of alpha' martensite
    jobEpsilon = defineJob(ebsd, grains, 'Epsilon', 'AlphaP');
    failed = snap(failed, dirs, 'plotMap_IPF_p2c', ...
                  @() plotMap_IPF_p2c(jobEpsilon, vector3d.Z, 'linewidth', 2));
    failed = snap(failed, dirs, 'plotMap_gB_c2c', ...
                  @() plotMap_gB_c2c(job, 'linewidth', 2));
    failed = snap(failed, dirs, 'plotMap_gB_p2c', @() plotMap_gB_p2c(job, 'linewidth', 1.5));

    %% Report
    if isempty(failed)
        screenPrint('SegmentStart', 'All documentation images were generated');
    else
        error('make_doc_images:failed', 'Failed to generate:\n  %s', strjoin(failed, '\n  '));
    end
end

function failed = snap(failed, dirs, name, plotFun, panels)
    %% Run a plotting function and save the figure(s) it opens as PNG
    % Every figure is saved to the review folder as <name>_<n>.png. The
    % documentation image <name>.png is made of the figures in "panels":
    %  n            - figure number(s), placed side by side (default: 1)
    %  [1 3; 2 4]   - a grid, one matrix row per image row (0 = empty)
    %  'gridN'      - all figures, N per row, each fitted into a cell of the
    %                 same size
    if nargin < 5
        panels = 1;
    end
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
            % Docked figures that were never shown are not drawn, so bring
            % each one to the front before exporting it
            figure(figs(ii));
            drawnow;
            exportgraphics(figs(ii), reviewFile(dirs, name, ii), 'Resolution', 150);
        end
        cellSize = [];
        if ischar(panels)
            nCols = str2double(panels(5:end));
            cellSize = [450 600];
            panels = 1:numel(figs);
            panels(end + 1:nCols * ceil(numel(figs) / nCols)) = 0;
            panels = reshape(panels, nCols, []).';
        end
        panels(panels > numel(figs)) = 0;
        rows = cell(size(panels, 1), 1);
        for rr = 1:size(panels, 1)
            imgs = arrayfun(@(ii) readPanel(dirs, name, ii), panels(rr, :), 'UniformOutput', false);
            if ~isempty(cellSize)
                imgs = cellfun(@(im) fitCell(im, cellSize), imgs, 'UniformOutput', false);
            end
            rows{rr} = sideBySide(imgs);
        end
        imwrite(stacked(rows), fullfile(dirs.images, [name, '.png']));
        screenPrint('Step', sprintf('Saved %s (figure(s) %s of %d)', name, mat2str(panels), numel(figs)));
    catch err
        failed{end + 1} = sprintf('%s: %s', name, err.message);
        screenPrint('Step', sprintf('FAILED %s: %s', name, err.message));
    end
    close all;
end

function fileName = reviewFile(dirs, name, ii)
    %% File name of the ii-th figure of a function in the review folder
    fileName = fullfile(dirs.review, sprintf('%s_%d.png', name, ii));
end

function img = readPanel(dirs, name, ii)
    %% Image of the ii-th figure of a function (empty for 0)
    img = uint8([]);
    if ii > 0
        img = imread(reviewFile(dirs, name, ii));
    end
end

function img = fitCell(im, cellSize)
    %% Scale an image to fit a cell of [height width] and centre it on white
    % (an empty image gives an empty white cell, which keeps the grid aligned)
    if isempty(im)
        img = 255 * ones([cellSize, 3], 'uint8');
        return
    end
    scale = min(cellSize ./ [size(im, 1), size(im, 2)]);
    im = imresize(im, min(cellSize, round(scale * [size(im, 1), size(im, 2)])));
    img = 255 * ones([cellSize, 3], 'like', im);
    top = floor((cellSize(1) - size(im, 1)) / 2);
    left = floor((cellSize(2) - size(im, 2)) / 2);
    img(top + (1:size(im, 1)), left + (1:size(im, 2)), :) = im;
end

function img = stacked(rows)
    %% Place images below each other, centred horizontally on white
    width = max(cellfun(@(im) size(im, 2), rows));
    for ii = 1:numel(rows)
        im = rows{ii};
        padding = width - size(im, 2);
        left = floor(padding / 2);
        white = @(cols) 255 * ones(size(im, 1), cols, 3, 'like', im);
        rows{ii} = [white(left), im, white(padding - left)];
    end
    img = vertcat(rows{:});
end

function img = sideBySide(imgs)
    %% Place RGB images next to each other, centred vertically on white
    imgs = imgs(~cellfun(@isempty, imgs));
    height = max(cellfun(@(im) size(im, 1), imgs));
    for ii = 1:numel(imgs)
        im = imgs{ii};
        if size(im, 3) == 1
            im = repmat(im, 1, 1, 3);
        end
        padding = height - size(im, 1);
        top = floor(padding / 2);
        white = @(rows) 255 * ones(rows, size(im, 2), 3, 'like', im);
        imgs{ii} = [white(top); im; white(padding - top)];
    end
    img = [imgs{:}];
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
    for ii = 2:numel(ebsd.mineralList)
        for jj = 1:size(renames, 1)
            if contains(lower(ebsd.mineralList{ii}), lower(renames{jj, 1}))
                ebsd.CSList(ii).mineral = renames{jj, 2};
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
    for ii = 2:numel(ebsd.mineralList)
        if strcmp(ebsd.mineralList{ii}, name)
            cs = ebsd.CSList(ii);
            return
        end
    end
    error('make_doc_images:phase', 'Phase ''%s'' not found', name);
end
