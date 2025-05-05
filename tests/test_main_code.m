classdef test_main_code < matlab.unittest.TestCase
    methods (Test)
        function testFunctionOutput(testCase)
            % Test if the function output is as expected
            actualOutput = main_code(5);
            expectedOutput = 25;
            testCase.verifyEqual(actualOutput, expectedOutput);
        end
    end
end
