import boto3




def list_queues(all=False):
    
    batch = boto3.client('batch')

    queues = []
    
    resp = batch.describe_job_queues()
    while True:
        qresp = resp['jobQueues']
        for q in qresp:
            if all == True or (q['state'] == 'ENABLED' and q['status'] == 'VALID'):
                queues.append(q)
            
        next_token = resp.get('nextToken', None)
        if next_token is None:
            break
        
        resp = batch.describe_job_queues(nextToken=next_token)
    
    return queues


