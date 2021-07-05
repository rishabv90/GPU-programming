##############################################################################
#
# HW Launcher
#
# Aaron Blood
#
import argparse
import os
import sys
import json
import time

def printValueByMsg(fileName, msg, value, occurrenceNum):
  cnt = 1
  with open(fileName) as fp:
    for line in fp:
      d = json.loads(line)
      if 'message' in d['data']:
        if d['data']['message'] == msg:
          if value in d['data']:
            if cnt == occurrenceNum:
              print value + ':', d['data'][value], 'of', msg
              return int(d['data'][value])
            else:
              cnt += 1

def printValueInMsg(fileName, msg):
  with open(fileName) as fp:
    for line in fp:
      d = json.loads(line)
      if 'message' in d['data']:
        if msg in d['data']['message']:
          print d['data']['message']
          return float(d['data']['message'].replace(msg,'').replace(' ',''))

def checkSolution(fileName):
  with open(fileName) as fp:
    for line in fp:
      d = json.loads(line)
      if 'correctq' in d['data']:
        print d['data']['message']
        if 'The solution is correct' in d['data']['message']:
          return True
        else:
          return False

parser = argparse.ArgumentParser(description='HW Launcher')
parser.add_argument("setTimes",type=int, help="Set number and number of times. This can include any number of arguments but must be a multiple of 2 total."
                    + "For example, to launch set #1 10 times and set #2 6 times: hw_launcher 1 10 2 6", nargs="+")
args = parser.parse_args()
setNum=0
times=0
if  len(args.setTimes) % 2:
  print "Error: Odd number of command line arguments, must supply a number of times value for each set"
  sys.exit()
else:
  os.system('rm histogram_output_*');
  for i in range(0,len(args.setTimes)/2):
    setNum=args.setTimes[i*2]
    times=args.setTimes[i*2+1]
    command = 'cp Histogram/Dataset/' + str(setNum) + '/* ./'
    print 'running ' + command
    os.system(command)
    for j in range(1,times+1):
      command = 'sed \"s/histogram_output/'+ 'histogram_output_' + str(setNum) + '_' + str(j) + '/g\" < lsf_histogram.sh | bsub'
      print 'running ' + command
      os.system(command)
    #Wait for all job(s) to be finished
    print "Waiting for",str(times),"job(s) to finish..."
    bjobs = 'JOBID'
    while 'JOBID' in bjobs:
      bjobs = os.popen('bjobs').read()
      time.sleep(3)

  #Parse each mode each time
  for i in range(0,len(args.setTimes)/2):
    setNum=args.setTimes[i*2]
    times=args.setTimes[i*2+1]
    verOneSum = 0
    verTwoSum = 0
    verThrSum = 0
    for j in range(1,times+1):
      fileName = 'histogram_output_' + str(setNum) + '_' + str(j) + '.txt'
      verOneSum += printValueByMsg(fileName,'Copying input memory to the GPU.','elapsed_time',1)
      verTwoSum += printValueByMsg(fileName,'Copying input memory to the GPU.','elapsed_time',1) #This happens only once, have to use number in both
      verOneSum += printValueByMsg(fileName,'Performing CUDA computation','elapsed_time',1)
      verTwoSum += printValueByMsg(fileName,'Performing CUDA computation','elapsed_time',2)
      verOneSum += printValueByMsg(fileName,'Copying output memory to the CPU','elapsed_time',1)
      verTwoSum += printValueByMsg(fileName,'Copying output memory to the CPU','elapsed_time',2)
      #verThrSum += printValueInMsg(fileName,'Elapsed kernel time (Version 3):')

    print "-----Set #" + str(setNum) + " results: ------"
    checkSolution(fileName)
    print "Version 1 Average:", str(verOneSum/(times * 1.0))
    print "Version 2 Average:", str(verTwoSum/(times * 1.0))
    #print "Version 3 Average:", str(verThrSum/(times * 1.0))
    print "---------------------------"