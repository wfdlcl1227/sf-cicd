import { LightningElement } from 'lwc';
import callLambda from '@salesforce/apex/LambdaCallout.callLambda';

export default class ExportAccounts extends LightningElement {
    exportAccounts() {
        callLambda()
            .then((result) => {
                
                let jsonResponse = JSON.parse(result);
                let responseBody = JSON.parse(jsonResponse.body);
                console.log('S3 URL1:', responseBody.url);
                console.log('S3 URL2:', jsonResponse.body);
                console.log('S3 URL3:', jsonResponse.statusCode);
                // Download the file from the S3 URL
                let link = document.createElement('a');
                link.href = responseBody.url;
                link.target = '_blank';
                link.download = 'Accounts.xlsx';
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
            })
            .catch((error) => {
                console.error('Error:', error);
            });
    }
    
}