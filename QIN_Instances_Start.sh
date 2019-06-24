#region us-east-1
#The code waits for 105 seconds and then stop trying to start that instance except db size

array_qin_instance_id=(i-0bd6fd9f8fa7ac195 i-092bae92f3aceac95 i-0ba3ede06b742ace5 i-00b23a4c53fe7d2d5 i-0473288358052fab8 i-094a89b9b3e616fb8 i-024a4d2a817749de1 i-0cd483b71007ba0c2 i-07e3900d9550f89e5 i-0b09e7660bc6d0b4d i-00f02f7942535a2d9 i-02b351e3326ba5bb3 i-0bb5182ed8ef0b476 i-02620c9d876863d59 i-09d7de12f3255ff2f i-09d7de12f3255ff2f i-07b8ec6871df882fe)
j=1;
maxtimes=50
timess=0

for se in ${array_qin_instance_id[@]}; do
	echo "$j -- $se"

	abc=`aws ec2 start-instances --instance-ids ${se}`;
	
	xyz=`echo $abc | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["StartingInstances"][0]["CurrentState"]["Name"]'`;
	if [ "$xyz" != "running" ]; then
		sleep 5
		timess=0
		tes=`aws ec2 describe-instance-status --instance-ids ${se}`
		while [[ $tes == *"[]"* ]]
		do
			if [ $timess -lt $maxtimes ]; then
				sleep 2
				echo "Waiting for Instances Status change to Running";
				tes=`aws ec2 describe-instance-status --instance-ids ${se}`
				timess=$(( timess + 1 ))
			else
				echo "Waited for 105 secs but the status didnt changed to Running so skipping instance "
				break;
			fi
		done
		xyz=`echo $tes | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["InstanceStatuses"][0]["InstanceState"]["Name"]'`;

	fi	 
	echo $xyz;
	
	if [ $se == "i-0473288358052fab8" ]; then
                echo "DB Instance sleep time for 420 sec.";
		sleep 420
        fi
	
	j=$(( j + 1 ))
done

#commented the GD Autoscaling.
gd=`aws autoscaling update-auto-scaling-group --auto-scaling-group-name qin-discovery --desired-capacity 1 --min-size 1 --max-size 1`;
tomcat=`aws autoscaling update-auto-scaling-group --auto-scaling-group-name tomcat_asg_v1 --desired-capacity 1 --min-size 1 --max-size 1`;
echo "GlobalDiscovery AutoScaling Instance Execution: "$gd;
echo "Tomcat AutoScaling Instance Execution: "$tomcat;
exit 0

